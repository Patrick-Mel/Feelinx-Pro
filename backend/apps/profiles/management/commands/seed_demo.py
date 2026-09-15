import random
from datetime import date, timedelta
from django.core.management.base import BaseCommand
from django.utils import timezone
from apps.accounts.models import User
from apps.profiles.models import Profile, Interest, Preference, Photo
from apps.payments.models import Plan
from apps.discovery.models import Swipe, Match
from apps.chat.models import Conversation, Message

INTERESTS_DATA = [
    # Culture & Musique
    {"code": "afrobeats", "name_fr": "Afrobeats", "name_en": "Afrobeats", "emoji": "🎵", "category": "music"},
    {"code": "makossa", "name_fr": "Makossa & Bikutsi", "name_en": "Makossa & Bikutsi", "emoji": "🎷", "category": "music"},
    {"code": "amapiano", "name_fr": "Amapiano", "name_en": "Amapiano", "emoji": "🎧", "category": "music"},
    {"code": "nollywood", "name_fr": "Cinéma Nollywood", "name_en": "Nollywood Cinema", "emoji": "🎬", "category": "culture"},
    {"code": "fashion", "name_fr": "Mode & Sape", "name_en": "Fashion", "emoji": "👗", "category": "style"},
    # Gastronomie & Lifestyle
    {"code": "ndole", "name_fr": "Cuisine Africaine", "name_en": "African Food", "emoji": "🍲", "category": "food"},
    {"code": "bbq", "name_fr": "Soya & Grillades", "name_en": "BBQ & Street Food", "emoji": "🥩", "category": "food"},
    {"code": "coffee", "name_fr": "Café & Brasseries", "name_en": "Coffee & Chill", "emoji": "☕", "category": "food"},
    {"code": "lounge", "name_fr": "Snacks & Lounges", "name_en": "Lounges & Nightlife", "emoji": "🍸", "category": "lifestyle"},
    # Sport & Loisirs
    {"code": "football", "name_fr": "Football & Lions", "name_en": "Football", "emoji": "⚽", "category": "sports"},
    {"code": "fitness", "name_fr": "Fitness & Gym", "name_en": "Fitness & Gym", "emoji": "🏋️", "category": "sports"},
    {"code": "travel", "name_fr": "Voyages & Ecotourisme", "name_en": "Travel", "emoji": "✈️", "category": "hobbies"},
    {"code": "gaming", "name_fr": "Jeux Vidéo / PS5", "name_en": "Gaming", "emoji": "🎮", "category": "hobbies"},
    {"code": "reading", "name_fr": "Lecture & Littérature", "name_en": "Reading", "emoji": "📚", "category": "hobbies"},
    # Business & Pro
    {"code": "tech", "name_fr": "Tech & Startups", "name_en": "Tech & Startups", "emoji": "💻", "category": "pro"},
    {"code": "business", "name_fr": "Entrepreneuriat", "name_en": "Entrepreneurship", "emoji": "💼", "category": "pro"},
    {"code": "crypto", "name_fr": "Web3 & Finance", "name_en": "Crypto & Finance", "emoji": "📈", "category": "pro"},
    # Valeurs & Spiritualité
    {"code": "church", "name_fr": "Foi & Église", "name_en": "Faith & Church", "emoji": "⛪", "category": "values"},
    {"code": "family", "name_fr": "Valeurs Familiales", "name_en": "Family Values", "emoji": "👨‍👩‍👧", "category": "values"},
    {"code": "nature", "name_fr": "Randonnée & Nature", "name_en": "Nature & Outdoors", "emoji": "🌿", "category": "lifestyle"},
]

FIRST_NAMES_FEMALE = [
    "Manuella", "Cynthia", "Vanessa", "Brenda", "Audrey", "Danielle", "Christelle", "Raïssa",
    "Sandrine", "Carine", "Patricia", "Sonia", "Fiona", "Grace", "Jessica", "Inès", "Mireille",
    "Esther", "Clarisse", "Nathalie", "Béatrice", "Carole", "Aline", "Evelyne", "Priscille"
]

FIRST_NAMES_MALE = [
    "Steve", "Franck", "Armel", "Kevin", "Cedric", "Boris", "Patrick", "Christian",
    "Stephane", "Landry", "Hervé", "Gael", "Thierry", "Brice", "Fabrice", "Romain",
    "Wilfried", "Rodrigue", "Serge", "Guy", "Arnaud", "Michel", "Yves", "Yannick", "Donald"
]

CITIES = [
    {"city": "Yaoundé", "neighborhood": "Bastos", "lat": 3.8780, "lng": 11.5121},
    {"city": "Yaoundé", "neighborhood": "Omnisports", "lat": 3.8820, "lng": 11.5300},
    {"city": "Douala", "neighborhood": "Bonapriso", "lat": 4.0320, "lng": 9.6920},
    {"city": "Douala", "neighborhood": "Akwa", "lat": 4.0500, "lng": 9.7000},
    {"city": "Bafoussam", "neighborhood": "Centre-ville", "lat": 5.4770, "lng": 10.4170},
    {"city": "Abidjan", "neighborhood": "Cocody", "lat": 5.3599, "lng": -4.0083},
]

BIOS = [
    "Passionnée par la tech, le Makossa et la bonne cuisine. Cherche une belle relation sincère et basée sur le respect. 😊",
    "Entrepreneur dans l'âme, toujours entre deux projets. J'adore voyager, jouer au foot le week-end et découvrir de nouveaux lounges.",
    "Souriante, calme et ambitieuse. Je cherche à élargir mon cercle d'amis et qui sait, trouver l'âme sœur ! 🌹",
    "Ingénieur logiciel à Yaoundé. Fan d'Afrobeats, de fitness et de débats passionnés autour d'un bon café.",
    "Simple, authentique et sans prise de tête. J'aime la musique, les sorties le week-end et les discussions profondes.",
]

AVATARS_FEMALE = [
    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600&auto=format&fit=crop",
]

AVATARS_MALE = [
    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=600&auto=format&fit=crop",
]

class Command(BaseCommand):
    help = "Seed initial demo data (interests, plans, 50 demo profiles, swipes, matches, and chats)."

    def handle(self, *args, **kwargs):
        self.stdout.write("Seeding data Feelinx...")

        # 1. Interests
        interests_objs = []
        for item in INTERESTS_DATA:
            obj, _ = Interest.objects.update_or_create(
                code=item["code"],
                defaults={
                    "name_fr": item["name_fr"],
                    "name_en": item["name_en"],
                    "emoji": item["emoji"],
                    "category": item["category"],
                }
            )
            interests_objs.append(obj)
        self.stdout.write(f"[OK] {len(interests_objs)} centres d'intérêt créés.")


        # 2. Subscription Plans
        Plan.objects.update_or_create(
            code="premium_1m",
            defaults={"name_fr": "Feelinx Premium 1 Mois", "name_en": "Feelinx Premium 1 Month", "duration_days": 30, "price_xaf": 3000, "is_popular": False}
        )
        Plan.objects.update_or_create(
            code="premium_3m",
            defaults={"name_fr": "Feelinx Premium 3 Mois", "name_en": "Feelinx Premium 3 Months", "duration_days": 90, "price_xaf": 7500, "is_popular": True}
        )
        Plan.objects.update_or_create(
            code="premium_12m",
            defaults={"name_fr": "Feelinx Premium 12 Mois", "name_en": "Feelinx Premium 1 Year", "duration_days": 365, "price_xaf": 24000, "is_popular": False}
        )
        self.stdout.write("[OK] 3 formules d'abonnement créées.")

        # 3. Create Demo Profiles
        profiles_created = []

        # Create 25 females and 25 males
        for i in range(50):
            is_female = (i % 2 == 0)
            gender = 'female' if is_female else 'male'
            first_name = random.choice(FIRST_NAMES_FEMALE) if is_female else random.choice(FIRST_NAMES_MALE)
            phone = f"+2376900000{i:02d}"

            user, _ = User.objects.get_or_create(phone_number=phone)
            user.is_phone_verified = True
            user.save()

            location = random.choice(CITIES)
            birth_year = random.randint(1995, 2005)

            profile, _ = Profile.objects.get_or_create(
                user=user,
                defaults={
                    "first_name": first_name,
                    "birth_date": date(birth_year, random.randint(1, 12), random.randint(1, 28)),
                    "gender": gender,
                    "seeking": 'male' if is_female else 'female',
                    "intention": random.choice(['serious', 'casual', 'friendship', 'networking']),
                    "bio": random.choice(BIOS),
                    "city": location["city"],
                    "neighborhood": location["neighborhood"],
                    "latitude": location["lat"] + random.uniform(-0.01, 0.01),
                    "longitude": location["lng"] + random.uniform(-0.01, 0.01),
                    "is_verified": (i % 3 == 0),
                    "is_premium": (i % 5 == 0),
                    "personality_answers": {"q1": "night", "q2": "beach", "q3": "spicy"},
                }
            )

            # Preferences
            Preference.objects.get_or_create(
                profile=profile,
                defaults={
                    "min_age": 18,
                    "max_age": 45,
                    "max_distance_km": 50,
                    "preferred_genders": ['male'] if is_female else ['female'],
                }
            )

            # Assign 3 to 6 interests
            selected_interests = random.sample(interests_objs, random.randint(3, 6))
            profile.interests.set(selected_interests)

            profiles_created.append(profile)

        self.stdout.write(f"[OK] {len(profiles_created)} profils de démonstration générés.")

        # 4. Generate Swipes & Matches
        match_count = 0
        for idx in range(15):
            p1 = profiles_created[idx * 2]
            p2 = profiles_created[idx * 2 + 1]

            # Mutual Likes
            Swipe.objects.update_or_create(swiper=p1, swiped=p2, defaults={'action': 'like'})
            Swipe.objects.update_or_create(swiper=p2, swiped=p1, defaults={'action': 'like'})

            p_a, p_b = (p1, p2) if p1.id < p2.id else (p2, p1)
            match_obj, _ = Match.objects.get_or_create(profile_a=p_a, profile_b=p_b, defaults={'is_active': True})
            conv, _ = Conversation.objects.get_or_create(match=match_obj)

            # Create sample conversation messages
            Message.objects.create(
                conversation=conv,
                sender=p1,
                content=f"Salut {p2.first_name} ! Ravi de matcher avec toi 😊",
                message_type='text',
                status='read'
            )
            Message.objects.create(
                conversation=conv,
                sender=p2,
                content=f"Coucou {p1.first_name} ! Comment vas-tu ? J'ai vu qu'on partageait l'intérêt pour le Makossa !",
                message_type='text',
                status='read'
            )
            match_count += 1

        self.stdout.write(f"[OK] {match_count} matchs et conversations démo créés.")
        self.stdout.write(self.style.SUCCESS("Seeding Feelinx terminé avec succès !"))


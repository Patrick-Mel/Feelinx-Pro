import random
from datetime import date
from django.core.management.base import BaseCommand
from apps.accounts.models import User
from apps.profiles.models import Profile, Interest, Preference, Photo
from apps.payments.models import Plan
from apps.discovery.models import Swipe, Match
from apps.chat.models import Conversation, Message

INTERESTS_DATA = [
    # Culture & Musique
    {"code": "afrobeats", "name_fr": "Afrobeats & Musique", "name_en": "Afrobeats & Music", "category": "music"},
    {"code": "makossa", "name_fr": "Makossa & Bikutsi", "name_en": "Makossa & Bikutsi", "category": "music"},
    {"code": "amapiano", "name_fr": "Amapiano & Dance", "name_en": "Amapiano & Dance", "category": "music"},
    {"code": "nollywood", "name_fr": "Cinéma & Théâtre", "name_en": "Cinema & Theater", "category": "culture"},
    {"code": "fashion", "name_fr": "Mode & Élégance", "name_en": "Fashion & Style", "category": "style"},
    # Gastronomie & Lifestyle
    {"code": "ndole", "name_fr": "Gastronomie Africaine", "name_en": "African Cuisine", "category": "food"},
    {"code": "bbq", "name_fr": "Grillades & Barbecue", "name_en": "BBQ & Street Food", "category": "food"},
    {"code": "coffee", "name_fr": "Café & Dégustation", "name_en": "Coffee & Chill", "category": "food"},
    {"code": "lounge", "name_fr": "Sorties & Lounges", "name_en": "Lounges & Nightlife", "category": "lifestyle"},
    # Sport & Loisirs
    {"code": "football", "name_fr": "Football & Sports", "name_en": "Football & Sports", "category": "sports"},
    {"code": "fitness", "name_fr": "Fitness & Musculation", "name_en": "Fitness & Gym", "category": "sports"},
    {"code": "travel", "name_fr": "Voyages & Découvertes", "name_en": "Travel & Exploration", "category": "hobbies"},
    {"code": "gaming", "name_fr": "Jeux Vidéo & E-Sport", "name_en": "Gaming & E-Sport", "category": "hobbies"},
    {"code": "reading", "name_fr": "Lecture & Littérature", "name_en": "Reading & Books", "category": "hobbies"},
    # Business & Pro
    {"code": "tech", "name_fr": "Tech & Innovation", "name_en": "Tech & Innovation", "category": "pro"},
    {"code": "business", "name_fr": "Entrepreneuriat", "name_en": "Entrepreneurship", "category": "pro"},
    {"code": "crypto", "name_fr": "Finance & Investissement", "name_en": "Finance & Investments", "category": "pro"},
    # Valeurs & Spiritualité
    {"code": "church", "name_fr": "Foi & Spiritualité", "name_en": "Faith & Spirituality", "category": "values"},
    {"code": "family", "name_fr": "Valeurs Familiales", "name_en": "Family Values", "category": "values"},
    {"code": "nature", "name_fr": "Randonnée & Nature", "name_en": "Nature & Outdoors", "category": "lifestyle"},
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
    {"city": "Douala (Cameroun)", "neighborhood": "Bonapriso", "lat": 4.0320, "lng": 9.6920},
    {"city": "Yaoundé (Cameroun)", "neighborhood": "Bastos", "lat": 3.8780, "lng": 11.5121},
    {"city": "Bafoussam (Cameroun)", "neighborhood": "Centre-ville", "lat": 5.4770, "lng": 10.4170},
    {"city": "Abidjan (Côte d'Ivoire)", "neighborhood": "Cocody", "lat": 5.3599, "lng": -4.0083},
    {"city": "Dakar (Sénégal)", "neighborhood": "Almadies", "lat": 14.7167, "lng": -17.4677},
    {"city": "Libreville (Gabon)", "neighborhood": "Louis", "lat": 0.3901, "lng": 9.4544},
]

BIOS = [
    "Passionnée par la technologie, la bonne musique et la gastronomie. Je recherche une belle relation sincère et fondée sur le respect mutuel.",
    "Entrepreneur passionné, toujours motivé par de nouveaux projets. J'aime les voyages, le sport et les échanges enrichissants.",
    "Souriante, ambitieuse et calme. Je souhaite faire de belles rencontres authentiques et partager de bons moments.",
    "Ingénieur résidant à Yaoundé. Amateur d'Afrobeats, de fitness et de débats passionnants autour d'un café.",
    "Authentique et enthousiaste. J'apprécie les sorties le week-end, l'art et les conversations profondes.",
]

AVATARS_FEMALE = [
    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1589156280159-27698a70f29e?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1523825036634-aab3cce05919?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=800&auto=format&fit=crop",
]

AVATARS_MALE = [
    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1463453091185-61582044d556?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1507081323647-4d250478b919?w=800&auto=format&fit=crop",
]

class Command(BaseCommand):
    help = "Seed demo data with real HD African portraits, updated pricing, and professional formatting."

    def handle(self, *args, **kwargs):
        self.stdout.write("Génération des données de démonstration Feelinx...")

        # 1. Interests
        interests_objs = []
        for item in INTERESTS_DATA:
            obj, _ = Interest.objects.update_or_create(
                code=item["code"],
                defaults={
                    "name_fr": item["name_fr"],
                    "name_en": item["name_en"],
                    "emoji": "",
                    "category": item["category"],
                }
            )
            interests_objs.append(obj)
        self.stdout.write(f"[OK] {len(interests_objs)} centres d'intérêt mis à jour.")

        # 2. Subscription Plans
        Plan.objects.update_or_create(
            code="premium_1m",
            defaults={"name_fr": "Feelinx Premium 1 Mois", "name_en": "Feelinx Premium 1 Month", "duration_days": 30, "price_xaf": 1000, "is_popular": False}
        )
        Plan.objects.update_or_create(
            code="premium_3m",
            defaults={"name_fr": "Feelinx Premium 3 Mois", "name_en": "Feelinx Premium 3 Months", "duration_days": 90, "price_xaf": 2500, "is_popular": True}
        )
        Plan.objects.update_or_create(
            code="premium_12m",
            defaults={"name_fr": "Feelinx Premium 12 Mois", "name_en": "Feelinx Premium 1 Year", "duration_days": 365, "price_xaf": 10000, "is_popular": False}
        )
        self.stdout.write("[OK] Nouveaux tarifs d'abonnement configurés (1000, 2500, 10000 FCFA).")

        # 3. Create Demo Profiles
        profiles_created = []

        for i in range(50):
            is_female = (i % 2 == 0)
            gender = 'female' if is_female else 'male'
            first_name = random.choice(FIRST_NAMES_FEMALE) if is_female else random.choice(FIRST_NAMES_MALE)
            phone = f"+2376900000{i:02d}"

            user, _ = User.objects.get_or_create(phone_number=phone)
            user.is_phone_verified = True
            user.save()

            location = random.choice(CITIES)
            birth_year = random.randint(1995, 2004)

            profile, created = Profile.objects.get_or_create(
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

            # Ensure profile attributes are clean
            profile.city = location["city"]
            profile.save()

            # Attach 2 to 3 photos
            avatar_pool = AVATARS_FEMALE if is_female else AVATARS_MALE
            primary_url = avatar_pool[i % len(avatar_pool)]
            secondary_url = avatar_pool[(i + 1) % len(avatar_pool)]

            Photo.objects.filter(profile=profile).delete()
            Photo.objects.create(profile=profile, image=primary_url, is_primary=True, order=0)
            Photo.objects.create(profile=profile, image=secondary_url, is_primary=False, order=1)

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

        self.stdout.write(f"[OK] {len(profiles_created)} profils de démonstration mis à jour avec de vraies photos HD.")

        # 4. Generate Swipes & Matches
        match_count = 0
        for idx in range(15):
            p1 = profiles_created[idx * 2]
            p2 = profiles_created[idx * 2 + 1]

            Swipe.objects.update_or_create(swiper=p1, swiped=p2, defaults={'action': 'like'})
            Swipe.objects.update_or_create(swiper=p2, swiped=p1, defaults={'action': 'like'})

            p_a, p_b = (p1, p2) if p1.id < p2.id else (p2, p1)
            match_obj, _ = Match.objects.get_or_create(profile_a=p_a, profile_b=p_b, defaults={'is_active': True})
            conv, _ = Conversation.objects.get_or_create(match=match_obj)

            Message.objects.create(
                conversation=conv,
                sender=p1,
                content=f"Bonjour {p2.first_name}, ravi de matcher avec toi !",
                message_type='text',
                status='read'
            )
            Message.objects.create(
                conversation=conv,
                sender=p2,
                content=f"Bonjour {p1.first_name} ! Comment vas-tu ? J'ai vu tes centres d'intérêt sur ton profil.",
                message_type='text',
                status='read'
            )
            match_count += 1

        self.stdout.write(f"[OK] {match_count} matchs et conversations démo actifs.")
        self.stdout.write(self.style.SUCCESS("Génération Feelinx terminée avec succès !"))

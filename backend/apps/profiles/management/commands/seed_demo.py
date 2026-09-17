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
    {"code": "rumba", "name_fr": "Rumba Congolaise", "name_en": "Congolese Rumba", "category": "music"},
    {"code": "nollywood", "name_fr": "Cinéma & Théâtre", "name_en": "Cinema & Theater", "category": "culture"},
    {"code": "fashion", "name_fr": "Mode & Élégance Africaine", "name_en": "African Fashion & Style", "category": "style"},
    
    # Gastronomie & Lifestyle
    {"code": "ndole", "name_fr": "Gastronomie (Ndolè, Eru)", "name_en": "African Cuisine", "category": "food"},
    {"code": "bbq", "name_fr": "Grillades & Soya", "name_en": "BBQ & Street Food", "category": "food"},
    {"code": "coffee", "name_fr": "Café & Dégustation", "name_en": "Coffee & Chill", "category": "food"},
    {"code": "lounge", "name_fr": "Sorties & Lounges", "name_en": "Lounges & Nightlife", "category": "lifestyle"},
    
    # Sport & Loisirs
    {"code": "football", "name_fr": "Football & Lions Indomptables", "name_en": "Football & Sports", "category": "sports"},
    {"code": "fitness", "name_fr": "Fitness & Musculation", "name_en": "Fitness & Gym", "category": "sports"},
    {"code": "travel", "name_fr": "Voyages & Ecotourisme", "name_en": "Travel & Exploration", "category": "hobbies"},
    {"code": "gaming", "name_fr": "Jeux Vidéo & E-Sport", "name_en": "Gaming & E-Sport", "category": "hobbies"},
    {"code": "reading", "name_fr": "Lecture & Littérature", "name_en": "Reading & Books", "category": "hobbies"},
    
    # Business & Pro
    {"code": "tech", "name_fr": "Tech & Startup Africa", "name_en": "Tech & Innovation", "category": "pro"},
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
    "Esther", "Clarisse", "Nathalie", "Béatrice", "Carole", "Aline", "Evelyne", "Priscille",
    "Aminata", "Fatou", "Awa", "Mariama", "Adama", "Binta", "Khadija", "Chimamanda", "Ngozi",
    "Blessing", "Chiamaka", "Mercy", "Precious", "Zainab", "Keza", "Divine", "Sandra", "Yolande",
    "Edwige", "Tatiana", "Armelle", "Murielle", "Solange", "Delphine", "Honorine", "Brigitte",
    "Florence", "Rose", "Paule", "Germaine", "Henriette", "Pulchérie", "Rosine", "Sidonie", "Fabiola"
]

FIRST_NAMES_MALE = [
    "Steve", "Franck", "Armel", "Kevin", "Cedric", "Boris", "Patrick", "Christian",
    "Stephane", "Landry", "Hervé", "Gael", "Thierry", "Brice", "Fabrice", "Romain",
    "Wilfried", "Rodrigue", "Serge", "Guy", "Arnaud", "Michel", "Yves", "Yannick", "Donald",
    "Ibrahim", "Mamadou", "Ousmane", "Cheikh", "Moussa", "Bakary", "Seydou", "Tunde", "Kwame",
    "Koffi", "Femi", "Chidi", "Emeka", "Babajide", "Jean-Marc", "Jean-Paul", "Martial", "Gildas",
    "Romuald", "Bertin", "Dieudonné", "Fabien", "Florent", "Gilles", "Hector", "Ignace", "Joel",
    "Ludovic", "Norbert", "Olivier", "Pascal", "Quentin", "Raoul", "Salomon", "Théophile"
]

LAST_NAMES = [
    "Ndongo", "Mbida", "Ngo Ntamack", "Eboa", "Nsangou", "Bikono", "Fouda", "Talla", "Kamga",
    "Tchinda", "Mballa", "Nguema", "Manga", "Mvondo", "Atangana", "Biwolé", "Eboko", "Essomba",
    "Abena", "Nkembe", "Njoh", "Ntone", "Ekotto", "Kouam", "Nganou", "Tagne", "Fotso", "Wambo",
    "Djoko", "Moukoko", "Diop", "Traoré", "Koné", "Keita", "Diallo", "Coulibaly", "Touré", "Sow",
    "Ndiaye", "Faye", "Nzonzi", "Kouassi", "Koffi", "Mensah", "Owusu", "Okafor", "Okeke",
    "Adeleke", "Achebe", "Kagame", "Ndayishimiye", "Mbeki", "Zuma", "Tshisekedi", "Mutombo", "Ilunga"
]

CITIES = [
    # Cameroun (70% des profils)
    {"city": "Yaoundé (Cameroun)", "neighborhood": "Bastos", "lat": 3.8780, "lng": 11.5121},
    {"city": "Yaoundé (Cameroun)", "neighborhood": "Omnisports", "lat": 3.8820, "lng": 11.5240},
    {"city": "Yaoundé (Cameroun)", "neighborhood": "Odza", "lat": 3.8150, "lng": 11.5310},
    {"city": "Yaoundé (Cameroun)", "neighborhood": "Mendong", "lat": 3.8410, "lng": 11.4810},
    {"city": "Yaoundé (Cameroun)", "neighborhood": "Santa Barbara", "lat": 3.8910, "lng": 11.5290},
    {"city": "Douala (Cameroun)", "neighborhood": "Bonapriso", "lat": 4.0320, "lng": 9.6920},
    {"city": "Douala (Cameroun)", "neighborhood": "Akwa", "lat": 4.0500, "lng": 9.7000},
    {"city": "Douala (Cameroun)", "neighborhood": "Bonanjo", "lat": 4.0410, "lng": 9.6890},
    {"city": "Douala (Cameroun)", "neighborhood": "Makepe", "lat": 4.0810, "lng": 9.7420},
    {"city": "Douala (Cameroun)", "neighborhood": "Denver", "lat": 4.0750, "lng": 9.7350},
    {"city": "Bafoussam (Cameroun)", "neighborhood": "Centre-ville", "lat": 5.4770, "lng": 10.4170},
    {"city": "Garoua (Cameroun)", "neighborhood": "Roumdé Adjia", "lat": 9.3011, "lng": 13.3970},
    {"city": "Bamenda (Cameroun)", "neighborhood": "Commercial Avenue", "lat": 5.9631, "lng": 10.1591},
    {"city": "Kribi (Cameroun)", "neighborhood": "Ngoye Beach", "lat": 2.9372, "lng": 9.9079},
    {"city": "Limbe (Cameroun)", "neighborhood": "Down Beach", "lat": 4.0167, "lng": 9.2000},
    {"city": "Dschang (Cameroun)", "neighborhood": "Ville Haute", "lat": 5.4480, "lng": 10.0530},
    {"city": "Ebolowa (Cameroun)", "neighborhood": "Nko'ovos", "lat": 2.9000, "lng": 11.1500},
    
    # Métropoles Africaines (30% des profils)
    {"city": "Abidjan (Côte d'Ivoire)", "neighborhood": "Cocody", "lat": 5.3599, "lng": -4.0083},
    {"city": "Abidjan (Côte d'Ivoire)", "neighborhood": "Zone 4", "lat": 5.2950, "lng": -3.9850},
    {"city": "Dakar (Sénégal)", "neighborhood": "Almadies", "lat": 14.7167, "lng": -17.4677},
    {"city": "Libreville (Gabon)", "neighborhood": "Louis", "lat": 0.3901, "lng": 9.4544},
    {"city": "Kinshasa (RDC)", "neighborhood": "Gombe", "lat": -4.3033, "lng": 15.3147},
    {"city": "Brazzaville (Congo)", "neighborhood": "Bacongo", "lat": -4.2634, "lng": 15.2429},
    {"city": "Lomé (Togo)", "neighborhood": "Nyékonakpoè", "lat": 6.1375, "lng": 1.2125},
    {"city": "Cotonou (Bénin)", "neighborhood": "Haie Vive", "lat": 6.3654, "lng": 2.4183},
    {"city": "Kigali (Rwanda)", "neighborhood": "Nyarutarama", "lat": -1.9441, "lng": 30.0619},
]

BIOS = [
    "Passionnée par l'innovation, la bonne cuisine africaine et les moments chaleureux entre amis. Recherche une belle rencontre authentique.",
    "Entrepreneur passionné, toujours motivé par de nouveaux projets. J'aime les voyages, le sport et les échanges enrichissants.",
    "Souriante, calme et ambitieuse. J'aime les conversations profondes, la musique Afrobeats et les promenades le week-end.",
    "Ingénieur résidant à Yaoundé. Amateur d'Afrobeats, de fitness et de débats passionnants autour d'un bon café.",
    "Authentique et dynamique. J'apprécie l'art, les soirées en lounge et découvrir de magnifiques paysages.",
    "Juriste de formation, curieuse et élégante. Recherche un partenaire sérieux et équilibré.",
    "Passionné de football, de technologie et de gastronomie. Toujours souriant et ouvert aux belles opportunités de la vie.",
    "Médecin passionnée par mon métier, la lecture et les voyages. Recherche une relation sincère basée sur le respect.",
    "Architecte d'intérieur passionné de design. J'aime rire, voyager et partager de superbes repas en bonne compagnie.",
    "Directrice marketing, dynamique et positive. J'aime la vie, le sport et les projets d'avenir inspirants."
]

AVATARS_FEMALE = [
    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1589156280159-27698a70f29e?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1534751516642-a171e261452a?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1520813792240-56fc4a3765a7?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1554151228-14d9def656e4?w=800&auto=format&fit=crop",
]

AVATARS_MALE = [
    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1480429370139-e0132c086e2a?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1513956589380-bad6acb9b9d4?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1566492031773-4f4e44671857?w=800&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&auto=format&fit=crop",
]

class Command(BaseCommand):
    help = "Seed 300 rich realistic African user profiles with HD portraits, full intentions, and demo interactions."

    def handle(self, *args, **kwargs):
        self.stdout.write("Génération de 300 utilisateurs africains crédibles pour Feelinx...")

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

        # 2.5 Create Superuser Admin Account
        admin_user, _ = User.objects.get_or_create(phone_number="+237689731055")
        admin_user.is_staff = True
        admin_user.is_superuser = True
        admin_user.is_active = True
        admin_user.is_phone_verified = True
        admin_user.set_password("Beerus sam@17")
        admin_user.save()

        admin_profile, _ = Profile.objects.get_or_create(
            user=admin_user,
            defaults={
                "first_name": "Beerus",
                "last_name": "Admin",
                "birth_date": date(1995, 1, 1),
                "gender": "male",
                "seeking": "female",
                "intention": "networking",
                "bio": "Superutilisateur Administrateur Feelinx Control Center.",
                "city": "Yaoundé (Cameroun)",
                "neighborhood": "Bastos",
                "latitude": 3.8780,
                "longitude": 11.5121,
                "is_verified": True,
                "is_premium": True,
            }
        )
        admin_profile.first_name = "Beerus"
        admin_profile.last_name = "Admin"
        admin_profile.save()
        self.stdout.write(self.style.SUCCESS("[OK] Compte Superutilisateur Admin créé (+237689731055 / Beerus sam@17)."))

        # 3. Create 300 Demo Profiles
        profiles_created = []

        for i in range(300):
            is_female = (i % 2 == 0)
            gender = 'female' if is_female else 'male'
            
            first_name = random.choice(FIRST_NAMES_FEMALE) if is_female else random.choice(FIRST_NAMES_MALE)
            last_name = random.choice(LAST_NAMES)
            full_display_name = f"{first_name} {last_name[0]}."
            
            phone = f"+23769000{i:04d}"

            user, _ = User.objects.get_or_create(phone_number=phone)
            user.is_phone_verified = True
            user.save()

            location = CITIES[i % len(CITIES)]
            birth_year = random.randint(1994, 2005)

            profile, created = Profile.objects.get_or_create(
                user=user,
                defaults={
                    "first_name": first_name,
                    "birth_date": date(birth_year, random.randint(1, 12), random.randint(1, 28)),
                    "gender": gender,
                    "seeking": 'male' if is_female else 'female',
                    "intention": random.choice(['serious', 'casual', 'friendship', 'networking', 'undecided']),
                    "bio": random.choice(BIOS),
                    "city": location["city"],
                    "neighborhood": location["neighborhood"],
                    "latitude": location["lat"] + random.uniform(-0.015, 0.015),
                    "longitude": location["lng"] + random.uniform(-0.015, 0.015),
                    "is_verified": (i % 3 == 0),
                    "is_premium": (i % 6 == 0),
                    "personality_answers": {"q1": "night", "q2": "beach", "q3": "spicy"},
                }
            )

            profile.first_name = first_name
            profile.last_name = last_name
            profile.city = location["city"]
            profile.neighborhood = location["neighborhood"]
            profile.save()

            # Attach 2 photos
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
                    "max_age": 50,
                    "max_distance_km": 100,
                    "preferred_genders": ['male'] if is_female else ['female'],
                }
            )

            # Assign 3 to 6 interests
            selected_interests = random.sample(interests_objs, random.randint(3, 6))
            profile.interests.set(selected_interests)

            profiles_created.append(profile)

        self.stdout.write(f"[OK] {len(profiles_created)} profils d'utilisateurs africains créés et mis à jour avec de vraies photos HD.")

        # 4. Generate Swipes & Matches for active demo experience
        match_count = 0
        for idx in range(30):
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
                content=f"Bonjour {p2.first_name}, ravie de matcher avec toi sur Feelinx !",
                message_type='text',
                status='read'
            )
            Message.objects.create(
                conversation=conv,
                sender=p2,
                content=f"Bonjour {p1.first_name} ! Comment vas-tu ? J'aime beaucoup ton profil !",
                message_type='text',
                status='read'
            )
            match_count += 1

        self.stdout.write(f"[OK] {match_count} matchs et conversations démo actifs générés.")
        self.stdout.write(self.style.SUCCESS("Génération Feelinx de 300 utilisateurs terminée avec succès !"))

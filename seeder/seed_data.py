import requests
import time
import os

API_URL = os.environ.get("API_URL", "http://api_gateway:8000")

def seed():
    print("⏳ Attente que l'API soit prête (ping sur /)...")
    for _ in range(30): # Attendre jusqu'à 60 secondes
        try:
            res = requests.get(f"{API_URL}/")
            if res.status_code == 200:
                break
        except requests.ConnectionError:
            pass
        time.sleep(2)
    else:
        print("❌ L'API n'est pas accessible. Assurez-vous que l'api_gateway est démarrée.")
        return

    print("✅ API Gateway accessible. Création des données...")

    # 1. Création Admin
    print("\n--- Création Admin ---")
    admin_data = {
        "full_name": "Admin Test",
        "email": "admin@test.com",
        "password": "admin123",
        "phone": "00000000"
    }
    res = requests.post(f"{API_URL}/auth/register", json=admin_data)
    if res.status_code == 200:
        print("✅ Admin créé avec succès")
    else:
        print(f"ℹ️ Admin existe déjà ou erreur : {res.json()}")

    # 2. Création Client
    print("\n--- Création Client ---")
    client_data = {
        "full_name": "Client Test",
        "email": "client@test.com",
        "password": "client123",
        "phone": "11111111"
    }
    res = requests.post(f"{API_URL}/auth/register", json=client_data)
    if res.status_code == 200:
        print("✅ Client créé avec succès")
    else:
        print(f"ℹ️ Client existe déjà ou erreur : {res.json()}")

    # 3. Récupérer un token Admin (On tente admin@test.com)
    login_res = requests.post(f"{API_URL}/auth/login", json={"email": "admin@test.com", "password": "admin123"})
    if login_res.status_code == 200:
        token = login_res.json()['access_token']
        headers = {"Authorization": f"Bearer {token}"}
        
        # Le endpoint users demande d'être admin. Par défaut le register crée un "client".
        # Dans un cas réel, il faudrait forcer le rôle en DB ou via un script spécifique, 
        # mais la route POST /products demande juste `Depends(verify_token)`. 
        # Testons si on peut ajouter les produits.
        
        print("\n--- Création des Produits ---")
        products = [
            {
                "name": "Tirage Classique 10x15",
                "category": "STANDARD",
                "description": "Le format classique idéal pour vos albums photos.",
                "price": 0.80,
                "main_image": "https://images.unsplash.com/photo-1558591710-4b4a1ae0f04d?q=80&w=600&auto=format&fit=crop"
            },
            {
                "name": "Tirage Carré 15x15",
                "category": "CARRÉ",
                "description": "Parfait pour imprimer vos souvenirs Instagram.",
                "price": 1.50,
                "main_image": "https://images.unsplash.com/photo-1516961642265-531546e84af2?q=80&w=600&auto=format&fit=crop"
            },
            {
                "name": "Pack Polaroid (x10)",
                "category": "VINTAGE",
                "description": "Donnez un look rétro à vos photos avec notre format Polaroid.",
                "price": 8.90,
                "main_image": "https://images.unsplash.com/photo-1526178613552-2b45c6c302f0?q=80&w=600&auto=format&fit=crop"
            }
        ]

        for p in products:
            res = requests.post(f"{API_URL}/products", json=p, headers=headers)
            if res.status_code == 200:
                print(f"✅ Produit ajouté : {p['name']}")
            else:
                print(f"ℹ️ Info produit {p['name']} : {res.text}")

        print("\n🎉 Données de test insérées avec succès ! Vous pouvez maintenant tester l'application.")
    else:
        print(f"❌ Impossible de se connecter en tant qu'admin: {login_res.text}")

if __name__ == "__main__":
    seed()

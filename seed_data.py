import requests
import time

API_URL = "http://localhost:8000"

def seed():
    print("[INFO] Attente que l'API soit prete...")
    for _ in range(15):
        try:
            res = requests.get(f"{API_URL}/")
            if res.status_code == 200:
                break
        except requests.ConnectionError:
            pass
        time.sleep(2)
    else:
        print("[ERROR] L'API n'est pas accessible. Assurez-vous que Docker tourne.")
        return

    print("[OK] API Gateway accessible. Creation des donnees...")

    # 1. Création de l'utilisateur Admin
    print("\n--- Création Admin ---")
    admin_data = {
        "full_name": "Admin Memorini",
        "email": "admin@memorini.com",
        "password": "password123",
        "phone": "12345678"
    }
    res = requests.post(f"{API_URL}/auth/register", json=admin_data)
    if res.status_code == 200:
        print("[OK] Admin cree avec succes")
    else:
        print(f"[INFO] Admin: {res.json()}")

    # Obtenir le token pour l'admin
    admin_token = None
    login_res = requests.post(f"{API_URL}/auth/login", json={"email": "admin@memorini.com", "password": "password123"})
    if login_res.status_code == 200:
        admin_token = login_res.json()["access_token"]
        print("[OK] Connexion Admin reussie")
    else:
        print(f"[ERROR] Echec de connexion Admin : {login_res.text}")

    # 2. Création d'un compte Client de test
    print("\n--- Création Client ---")
    client_data = {
        "full_name": "Client Test",
        "email": "client@memorini.com",
        "password": "password123",
        "phone": "87654321"
    }
    res = requests.post(f"{API_URL}/auth/register", json=client_data)
    if res.status_code == 200:
        print("[OK] Client cree avec succes")
    else:
        print(f"[INFO] Client: {res.json()}")

    # 3. Récupérer un token (en tant que admin par défaut pour insérer des produits)
    if admin_token:
        headers = {"Authorization": f"Bearer {admin_token}"}
        
        # 4. Création des produits
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
                print(f"[OK] Produit ajoute : {p['name']}")
            else:
                print(f"[INFO] Erreur produit {p['name']} : {res.text}")

        print("\n[OK] Donnees de test inserees avec succes ! Vous pouvez maintenant tester l'application.")
    else:
        print("[ERROR] Impossible de se connecter pour ajouter des produits.")

if __name__ == "__main__":
    try:
        import requests
    except ImportError:
        print("[WARN] Le module 'requests' manque. Installez-le avec 'pip install requests' puis relancez.")
        exit(1)
    seed()

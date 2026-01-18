# Application Mobile E-commerce de Parfums

Application Flutter développée avec Material 3 et Supabase pour la gestion d'une boutique de parfums en ligne.

## 🚀 Fonctionnalités

### Interface Client
- ✅ Catalogue de parfums avec recherche et filtres
- ✅ Détails produits (notes, variantes, images)
- ✅ Panier d'achat
- ✅ Favoris
- ✅ Authentification (inscription/connexion)
- ✅ Historique des commandes
- ✅ Gestion des adresses
- ✅ Checkout avec paiement à la livraison

### Interface Admin
- ✅ Dashboard avec statistiques
- ✅ Gestion des commandes (changement de statut)
- ✅ Gestion des produits (CRUD)
- ✅ Upload d'images vers Supabase Storage

## 📋 Prérequis

- Flutter SDK (version stable)
- Compte Supabase
- Dart SDK ^3.9.2

## 🔧 Configuration

### 1. Configuration Supabase

1. Créez un projet sur [Supabase](https://supabase.com)
2. Créez les tables suivantes dans votre base de données PostgreSQL :

```sql
-- Table des profils utilisateurs
CREATE TABLE users_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  full_name TEXT,
  phone TEXT,
  role TEXT DEFAULT 'client' CHECK (role IN ('client', 'admin')),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Table des catégories
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE
);

-- Table des marques
CREATE TABLE brands (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE
);

-- Table des produits
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  brand_id UUID REFERENCES brands(id),
  category_id UUID REFERENCES categories(id),
  description TEXT,
  price NUMERIC(10, 2) NOT NULL,
  rating NUMERIC(3, 2),
  is_new BOOLEAN DEFAULT FALSE,
  is_top BOOLEAN DEFAULT FALSE,
  concentration TEXT,
  season TEXT,
  occasion TEXT,
  top_notes TEXT,
  heart_notes TEXT,
  base_notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Table des variantes de produits
CREATE TABLE product_variants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  volume_ml INTEGER NOT NULL,
  is_gift_set BOOLEAN DEFAULT FALSE,
  stock INTEGER DEFAULT 0,
  extra_price NUMERIC(10, 2) DEFAULT 0
);

-- Table des images de produits
CREATE TABLE product_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  is_cover BOOLEAN DEFAULT FALSE
);

-- Table des favoris
CREATE TABLE favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- Table des adresses
CREATE TABLE addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  city TEXT NOT NULL,
  address_line TEXT NOT NULL,
  zip TEXT NOT NULL,
  is_default BOOLEAN DEFAULT FALSE
);

-- Table des paniers
CREATE TABLE carts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Table des éléments du panier
CREATE TABLE cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cart_id UUID REFERENCES carts(id) ON DELETE CASCADE,
  variant_id UUID REFERENCES product_variants(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1,
  UNIQUE(cart_id, variant_id)
);

-- Table des commandes
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  address_id UUID REFERENCES addresses(id),
  delivery_mode TEXT NOT NULL,
  payment_method TEXT DEFAULT 'COD',
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled')),
  total NUMERIC(10, 2) NOT NULL,
  shipping_fee NUMERIC(10, 2) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Table des éléments de commande
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  variant_id UUID REFERENCES product_variants(id),
  unit_price NUMERIC(10, 2) NOT NULL,
  quantity INTEGER NOT NULL
);
```

3. Activez Row Level Security (RLS) sur toutes les tables
4. Créez les policies RLS nécessaires (voir section Sécurité ci-dessous)
5. Créez un bucket Storage nommé `product-images` dans Supabase Storage
6. Configurez les policies de storage pour permettre l'upload/lecture des images

### 2. Configuration de l'application

1. Ouvrez `lib/core/config/supabase_config.dart`
2. Remplacez `YOUR_SUPABASE_URL` par l'URL de votre projet Supabase
3. Remplacez `YOUR_SUPABASE_ANON_KEY` par votre clé anonyme Supabase

### 3. Installation des dépendances

```bash
flutter pub get
```

## 🔐 Sécurité (RLS Policies)

### Policies pour les clients

```sql
-- Products: Lecture pour tous
CREATE POLICY "Products are viewable by everyone"
  ON products FOR SELECT
  USING (true);

-- Product images: Lecture pour tous
CREATE POLICY "Product images are viewable by everyone"
  ON product_images FOR SELECT
  USING (true);

-- Product variants: Lecture pour tous
CREATE POLICY "Product variants are viewable by everyone"
  ON product_variants FOR SELECT
  USING (true);

-- Favorites: Gestion par l'utilisateur
CREATE POLICY "Users can manage their own favorites"
  ON favorites
  USING (auth.uid() = user_id);

-- Addresses: Gestion par l'utilisateur
CREATE POLICY "Users can manage their own addresses"
  ON addresses
  USING (auth.uid() = user_id);

-- Carts: Gestion par l'utilisateur
CREATE POLICY "Users can manage their own carts"
  ON carts
  USING (auth.uid() = user_id);

-- Cart items: Gestion par l'utilisateur
CREATE POLICY "Users can manage their own cart items"
  ON cart_items
  USING (
    EXISTS (
      SELECT 1 FROM carts
      WHERE carts.id = cart_items.cart_id
      AND carts.user_id = auth.uid()
    )
  );

-- Orders: Gestion par l'utilisateur
CREATE POLICY "Users can manage their own orders"
  ON orders
  USING (auth.uid() = user_id);

-- Order items: Lecture par l'utilisateur
CREATE POLICY "Users can view their own order items"
  ON order_items
  USING (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = order_items.order_id
      AND orders.user_id = auth.uid()
    )
  );
```

### Policies pour les admins

```sql
-- Products: CRUD pour les admins
CREATE POLICY "Admins can manage products"
  ON products
  USING (
    EXISTS (
      SELECT 1 FROM users_profiles
      WHERE users_profiles.id = auth.uid()
      AND users_profiles.role = 'admin'
    )
  );

-- Product images: CRUD pour les admins
CREATE POLICY "Admins can manage product images"
  ON product_images
  USING (
    EXISTS (
      SELECT 1 FROM users_profiles
      WHERE users_profiles.id = auth.uid()
      AND users_profiles.role = 'admin'
    )
  );

-- Product variants: CRUD pour les admins
CREATE POLICY "Admins can manage product variants"
  ON product_variants
  USING (
    EXISTS (
      SELECT 1 FROM users_profiles
      WHERE users_profiles.id = auth.uid()
      AND users_profiles.role = 'admin'
    )
  );

-- Orders: Lecture et modification pour les admins
CREATE POLICY "Admins can manage all orders"
  ON orders
  USING (
    EXISTS (
      SELECT 1 FROM users_profiles
      WHERE users_profiles.id = auth.uid()
      AND users_profiles.role = 'admin'
    )
  );

-- Users profiles: Lecture pour les admins
CREATE POLICY "Admins can view all user profiles"
  ON users_profiles
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users_profiles up
      WHERE up.id = auth.uid()
      AND up.role = 'admin'
    )
  );
```

## 🗄️ Fonctions SQL utiles

Créez ces fonctions pour gérer le stock :

```sql
-- Fonction pour décrémenter le stock
CREATE OR REPLACE FUNCTION decrement_stock(variant_id UUID, quantity INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE product_variants
  SET stock = stock - quantity
  WHERE id = variant_id AND stock >= quantity;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Stock insuffisant';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour incrémenter le stock
CREATE OR REPLACE FUNCTION increment_stock(variant_id UUID, quantity INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE product_variants
  SET stock = stock + quantity
  WHERE id = variant_id;
END;
$$ LANGUAGE plpgsql;
```

## 🏃 Exécution

```bash
flutter run
```

## 📱 Structure du projet

```
lib/
├── core/
│   ├── config/          # Configuration (Supabase)
│   ├── constants/       # Constantes de l'application
│   ├── routing/         # Configuration du routing
│   └── utils/           # Utilitaires
├── data/
│   ├── models/          # Modèles de données
│   ├── repositories/    # Repositories (accès données)
│   └── services/       # Services (Supabase)
└── presentation/
    ├── providers/       # Providers Riverpod
    ├── screens/         # Écrans de l'application
    └── widgets/         # Widgets réutilisables
```

## 🎨 Design

L'application utilise Material 3 avec un thème moderne et responsive. Les couleurs sont générées à partir d'une couleur de base (purple).

## 📝 Notes importantes

1. **Stockage des images** : Les images sont stockées dans Supabase Storage. Assurez-vous que le bucket `product-images` est configuré avec les bonnes permissions.

2. **Rôles utilisateurs** : Pour créer un utilisateur admin, modifiez directement le champ `role` dans la table `users_profiles` :
   ```sql
   UPDATE users_profiles SET role = 'admin' WHERE id = 'user_id';
   ```

3. **Paiement** : Actuellement, seul le paiement à la livraison (COD) est implémenté. Vous pouvez étendre cela pour ajouter d'autres méthodes de paiement.

4. **Validation** : Les formulaires incluent une validation de base. Vous pouvez améliorer la validation selon vos besoins.

## 🔄 Prochaines améliorations possibles

- [ ] Notifications push
- [ ] Système de reviews/avis
- [ ] Codes promo/réductions
- [ ] Recherche avancée avec filtres multiples
- [ ] Mode hors ligne avec synchronisation
- [ ] Intégration de méthodes de paiement en ligne
- [ ] Chat support client
- [ ] Recommandations de produits

## 📄 Licence

Ce projet est un exemple d'application e-commerce. Utilisez-le comme base pour vos propres projets.

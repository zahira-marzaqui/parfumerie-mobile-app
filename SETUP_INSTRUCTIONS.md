# Instructions de configuration Supabase

## 🚨 IMPORTANT : Les erreurs 400 sont normales si les tables n'existent pas encore

L'application fonctionne mais affiche des erreurs car les tables Supabase n'ont pas encore été créées. Suivez ces étapes :

## Étape 1 : Créer les tables dans Supabase

1. **Connectez-vous à Supabase** : https://supabase.com/dashboard
2. **Sélectionnez votre projet** (celui avec l'URL `matvzdncjpcirdftnkxh.supabase.co`)
3. **Allez dans l'éditeur SQL** (icône SQL dans le menu de gauche)
4. **Copiez-collez le contenu du fichier `supabase_setup.sql`**
5. **Cliquez sur "Run"** pour exécuter le script

## Étape 2 : Vérifier que les tables sont créées

1. Allez dans **Table Editor** (icône de table dans le menu)
2. Vous devriez voir les tables suivantes :
   - `users_profiles`
   - `categories`
   - `brands`
   - `products`
   - `product_variants`
   - `product_images`
   - `favorites`
   - `addresses`
   - `carts`
   - `cart_items`
   - `orders`
   - `order_items`

## Étape 3 : Créer des données de test

Exécutez ce script SQL dans l'éditeur SQL pour créer des données de test :

```sql
-- Insérer des catégories
INSERT INTO categories (name) VALUES 
  ('Homme'),
  ('Femme'),
  ('Unisexe'),
  ('Coffrets')
ON CONFLICT (name) DO NOTHING;

-- Insérer des marques
INSERT INTO brands (name) VALUES 
  ('Dior'),
  ('Chanel'),
  ('Yves Saint Laurent'),
  ('Tom Ford')
ON CONFLICT (name) DO NOTHING;

-- Insérer des produits de test
INSERT INTO products (name, price, category_id, brand_id, is_new, is_top, rating, description)
SELECT 
  'Sauvage',
  120.00,
  (SELECT id FROM categories WHERE name = 'Homme' LIMIT 1),
  (SELECT id FROM brands WHERE name = 'Dior' LIMIT 1),
  true,
  true,
  4.5,
  'Un parfum frais et épicé'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Sauvage');

INSERT INTO products (name, price, category_id, brand_id, is_new, is_top, rating, description)
SELECT 
  'Bleu de Chanel',
  95.00,
  (SELECT id FROM categories WHERE name = 'Homme' LIMIT 1),
  (SELECT id FROM brands WHERE name = 'Chanel' LIMIT 1),
  false,
  true,
  4.7,
  'Un parfum élégant et moderne'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Bleu de Chanel');

INSERT INTO products (name, price, category_id, brand_id, is_new, is_top, rating, description)
SELECT 
  'Black Opium',
  110.00,
  (SELECT id FROM categories WHERE name = 'Femme' LIMIT 1),
  (SELECT id FROM brands WHERE name = 'Yves Saint Laurent' LIMIT 1),
  true,
  false,
  4.6,
  'Un parfum sensuel et envoûtant'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Black Opium');

-- Insérer des variantes pour chaque produit
INSERT INTO product_variants (product_id, volume_ml, stock, extra_price)
SELECT 
  p.id,
  50,
  10,
  0.00
FROM products p
WHERE NOT EXISTS (
  SELECT 1 FROM product_variants pv 
  WHERE pv.product_id = p.id AND pv.volume_ml = 50
);

INSERT INTO product_variants (product_id, volume_ml, stock, extra_price)
SELECT 
  p.id,
  100,
  5,
  30.00
FROM products p
WHERE NOT EXISTS (
  SELECT 1 FROM product_variants pv 
  WHERE pv.product_id = p.id AND pv.volume_ml = 100
);
```

## Étape 4 : Configurer le Storage (pour les images)

1. Allez dans **Storage** dans le menu Supabase
2. Cliquez sur **"New bucket"**
3. Nommez-le `product-images`
4. Cochez **"Public bucket"** pour permettre l'accès public aux images
5. Cliquez sur **"Create bucket"**

## Étape 5 : Vérifier les policies RLS

Les policies de base ont été créées par le script SQL. Pour vérifier :

1. Allez dans **Authentication > Policies**
2. Sélectionnez la table `products`
3. Vous devriez voir la policy "Products are viewable by everyone"

## Étape 6 : Recharger l'application

Une fois les tables créées :
1. Rechargez votre application Flutter (hot restart)
2. Les erreurs 400 devraient disparaître
3. Vous devriez voir les produits de test s'afficher

## Vérification rapide

Pour tester si tout fonctionne, exécutez cette requête dans l'éditeur SQL :

```sql
SELECT COUNT(*) FROM products;
```

Si vous obtenez un nombre (même 0), les tables existent et fonctionnent !

## Problèmes courants

### "relation does not exist"
→ Les tables n'ont pas été créées. Exécutez `supabase_setup.sql`.

### "permission denied"
→ Les policies RLS bloquent l'accès. Vérifiez les policies dans Authentication > Policies.

### "column does not exist"
→ La structure de la table ne correspond pas. Vérifiez les noms des colonnes dans Table Editor.

### Erreurs 400 persistent après création des tables
→ Videz le cache du navigateur et rechargez l'application.

## Support

Si les erreurs persistent après avoir suivi ces étapes, vérifiez :
1. Que l'URL Supabase dans `supabase_config.dart` est correcte
2. Que la clé anonyme (anon key) est correcte
3. Les logs dans Supabase > Logs > API Logs pour voir les erreurs détaillées

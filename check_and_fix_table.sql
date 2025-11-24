-- recipes tablosunu kontrol et ve düzelt
USE flutter_app;

-- Önce mevcut tabloyu kontrol et
DESCRIBE recipes;

-- Eğer user_id kolonu yoksa veya tablo yanlışsa, şunu çalıştır:
-- Önce bağımlı tabloları sil
DROP TABLE IF EXISTS favorites;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS recipes;

-- recipes tablosunu doğru şekilde oluştur
CREATE TABLE recipes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  category_id INT,
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  ingredients TEXT NOT NULL,
  instructions TEXT NOT NULL,
  prep_time INT DEFAULT 0,
  cook_time INT DEFAULT 0,
  servings INT DEFAULT 1,
  difficulty VARCHAR(20) DEFAULT 'Orta',
  image_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
  INDEX idx_category (category_id),
  INDEX idx_user (user_id)
);

-- Favoriler tablosunu yeniden oluştur
CREATE TABLE favorites (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  recipe_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
  UNIQUE KEY unique_favorite (user_id, recipe_id),
  INDEX idx_user (user_id),
  INDEX idx_recipe (recipe_id)
);

-- Puanlar tablosunu yeniden oluştur
CREATE TABLE ratings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  recipe_id INT NOT NULL,
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
  UNIQUE KEY unique_rating (user_id, recipe_id),
  INDEX idx_user (user_id),
  INDEX idx_recipe (recipe_id)
);

-- Kontrol et
DESCRIBE recipes;


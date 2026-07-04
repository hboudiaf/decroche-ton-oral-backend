CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS students (
  id SERIAL PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  plan TEXT NOT NULL DEFAULT 'written',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  expires_at TIMESTAMP,
  oral_credits_total INTEGER NOT NULL DEFAULT 0,
  oral_credits_used INTEGER NOT NULL DEFAULT 0,
  must_change_password BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT students_plan_check CHECK (plan IN ('written', 'oral', 'complete', 'admin_grant')),
  CONSTRAINT students_credits_check CHECK (oral_credits_total >= 0 AND oral_credits_used >= 0 AND oral_credits_used <= oral_credits_total)
);

CREATE TABLE IF NOT EXISTS student_sessions (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  session_token TEXT UNIQUE NOT NULL DEFAULT encode(gen_random_bytes(32), 'hex'),
  expires_at TIMESTAMP NOT NULL,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS student_documents (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  file_path TEXT NOT NULL,
  required_plan TEXT NOT NULL DEFAULT 'written',
  position INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT documents_category_check CHECK (category IN ('science', 'shs', 'technique', 'questions')),
  CONSTRAINT documents_plan_check CHECK (required_plan IN ('written', 'oral', 'complete', 'admin_grant'))
);

CREATE TABLE IF NOT EXISTS student_download_logs (
  id SERIAL PRIMARY KEY,
  student_id INTEGER REFERENCES students(id) ON DELETE SET NULL,
  document_id INTEGER REFERENCES student_documents(id) ON DELETE SET NULL,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS student_booking_logs (
  id SERIAL PRIMARY KEY,
  student_id INTEGER REFERENCES students(id) ON DELETE SET NULL,
  booking_type TEXT NOT NULL,
  credits_used INTEGER NOT NULL DEFAULT 1,
  cal_link TEXT,
  notes TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_students_email ON students(email);
CREATE INDEX IF NOT EXISTS idx_student_sessions_token ON student_sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_student_sessions_student ON student_sessions(student_id);
CREATE INDEX IF NOT EXISTS idx_student_documents_category ON student_documents(category);
CREATE INDEX IF NOT EXISTS idx_student_documents_position ON student_documents(position);
CREATE INDEX IF NOT EXISTS idx_download_logs_student ON student_download_logs(student_id);
CREATE INDEX IF NOT EXISTS idx_booking_logs_student ON student_booking_logs(student_id);

INSERT INTO student_documents (position, title, category, file_path, required_plan)
VALUES
(1, 'Alfred Nobel', 'science', 'sequence-01-alfred-nobel.pdf', 'written'),
(2, 'Marie Curie — radium et polonium', 'science', 'sequence-02-marie-curie.pdf', 'written'),
(3, 'Le ribosome', 'science', 'sequence-03-ribosome.pdf', 'written'),
(4, 'CRISPR-Cas9', 'science', 'sequence-04-crispr-cas9.pdf', 'written'),
(5, 'Télomères et télomérase', 'science', 'sequence-05-telomeres-telomerase.pdf', 'written'),
(6, 'MicroARN', 'science', 'sequence-06-microarn.pdf', 'written'),
(7, 'HPV et VIH', 'science', 'sequence-07-hpv-vih.pdf', 'written'),
(8, 'Tolérance immunitaire périphérique', 'science', 'sequence-08-tolerance-immunitaire.pdf', 'written'),
(9, 'Structure de l’ADN', 'science', 'sequence-09-adn.pdf', 'written'),
(10, 'Vaccins à ARN messager', 'science', 'sequence-10-arn-messager.pdf', 'written'),
(11, 'Développement embryonnaire précoce', 'science', 'sequence-11-developpement-embryonnaire.pdf', 'written'),
(12, 'Georges Charpak', 'science', 'sequence-12-georges-charpak.pdf', 'written'),
(13, 'Albert Einstein', 'science', 'sequence-13-albert-einstein.pdf', 'written'),

(14, 'Ludwig van Beethoven', 'shs', 'sequence-14-beethoven.pdf', 'written'),
(15, 'Stromae', 'shs', 'sequence-15-stromae.pdf', 'written'),
(16, 'Grand Corps Malade', 'shs', 'sequence-16-grand-corps-malade.pdf', 'written'),
(17, 'Marcel Proust', 'shs', 'sequence-17-marcel-proust.pdf', 'written'),
(18, 'Boris Vian', 'shs', 'sequence-18-boris-vian.pdf', 'written'),
(19, 'Sylvain Tesson', 'shs', 'sequence-19-sylvain-tesson.pdf', 'written'),
(20, 'Amedeo Modigliani', 'shs', 'sequence-20-modigliani.pdf', 'written'),
(21, 'Claude Monet', 'shs', 'sequence-21-claude-monet.pdf', 'written'),
(22, 'Henri Toulouse-Lautrec', 'shs', 'sequence-22-toulouse-lautrec.pdf', 'written'),
(23, 'Vincent Van Gogh', 'shs', 'sequence-23-van-gogh.pdf', 'written'),
(24, 'Frida Kahlo', 'shs', 'sequence-24-frida-kahlo.pdf', 'written'),
(25, 'Camille Claudel', 'shs', 'sequence-25-camille-claudel.pdf', 'written')
ON CONFLICT DO NOTHING;

-- Prevent duplicate documents if the migration is run more than once.
CREATE UNIQUE INDEX IF NOT EXISTS idx_student_documents_file_path_unique
ON student_documents(file_path);

CREATE UNIQUE INDEX IF NOT EXISTS idx_student_documents_position_unique
ON student_documents(position);

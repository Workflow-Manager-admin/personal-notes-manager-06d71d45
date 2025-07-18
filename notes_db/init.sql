-- PostgreSQL Initialization Script for personal-notes-manager
-- Creates users and notes tables with necessary constraints and seed data

-- USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    hashed_password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- NOTES TABLE
CREATE TABLE IF NOT EXISTS notes (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Trigger to update updated_at on row update for users
CREATE OR REPLACE FUNCTION update_users_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS set_users_updated_at ON users;
CREATE TRIGGER set_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE PROCEDURE update_users_updated_at_column();

-- Trigger to update updated_at on row update for notes
CREATE OR REPLACE FUNCTION update_notes_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS set_notes_updated_at ON notes;
CREATE TRIGGER set_notes_updated_at
BEFORE UPDATE ON notes
FOR EACH ROW
EXECUTE PROCEDURE update_notes_updated_at_column();

-- SEED DATA (for dev/testing)

-- Remove existing test users and notes
DELETE FROM notes WHERE user_id IN (SELECT id FROM users WHERE username LIKE 'testuser%');
DELETE FROM users WHERE username LIKE 'testuser%';

-- Insert test users
INSERT INTO users (username, email, hashed_password)
VALUES
  ('testuser1', 'test1@example.com', '$2b$12$testhashforuser1'), -- bcrypt hash placeholder
  ('testuser2', 'test2@example.com', '$2b$12$testhashforuser2')
ON CONFLICT (username) DO NOTHING;

-- Insert sample notes for test users
INSERT INTO notes (user_id, title, content)
SELECT id, 'Welcome Note', 'This is your first note. Edit or delete it as you wish!'
FROM users WHERE username = 'testuser1';

INSERT INTO notes (user_id, title, content)
SELECT id, 'Demo Note', 'Testing multiple notes for user2'
FROM users WHERE username = 'testuser2';

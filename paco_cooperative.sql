-- PASCCO / Paco Savings & Credit Cooperative
-- FINAL INTEGRATED CLEAN-INSTALL SQL
-- BASE: user-supplied PASCCO_LATEST_ALL_REQUIRED_SQL.sql
-- Integrated with missing Phase 1 withdrawal approval schema and Phase 5 migration tracker.
--
-- IMPORTANT: For a NEW / EMPTY database only. Do not import over a populated database.
-- No old user accounts, MFA secrets, balances, transactions, loan data, or activity logs are seeded.
-- This creates schema only; it does not create an administrator login.
-- Tested by static inspection only; not executed against a live MariaDB server in this environment.

CREATE DATABASE IF NOT EXISTS `paco_cooperative` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `paco_cooperative`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;
--
-- Database: `paco_cooperative`
--

-- --------------------------------------------------------

--
-- Table structure for table `accounts`
--

CREATE TABLE `accounts` (
  `id` int(11) UNSIGNED NOT NULL,
  `member_id` int(11) UNSIGNED NOT NULL,
  `account_number` varchar(30) NOT NULL,
  `account_type` varchar(30) NOT NULL,
  `balance` decimal(15,2) NOT NULL,
  `status` enum('active','inactive') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `account_requests`
--

CREATE TABLE `account_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `member_id` int(10) UNSIGNED NOT NULL,
  `account_type` varchar(120) NOT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `admin_notes` text DEFAULT NULL,
  `requested_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `reviewed_by` int(10) UNSIGNED DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `announcements`
--

CREATE TABLE `announcements` (
  `id` int(10) UNSIGNED NOT NULL,
  `title` varchar(160) NOT NULL,
  `body` text NOT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  `published_at` datetime NOT NULL DEFAULT current_timestamp(),
  `status` enum('published','archived') NOT NULL DEFAULT 'published',
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `status` enum('success','failed') NOT NULL DEFAULT 'success',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `auth_throttle`
--

CREATE TABLE `auth_throttle` (
  `bucket` char(64) NOT NULL,
  `attempts` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `window_started` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `deposit_requests`
--

CREATE TABLE `deposit_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `account_id` int(10) UNSIGNED NOT NULL,
  `member_id` int(10) UNSIGNED NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `payment_method` varchar(40) NOT NULL,
  `payment_reference` varchar(120) NOT NULL,
  `description` varchar(255) NOT NULL,
  `receipt_path` varchar(255) NOT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `admin_notes` varchar(500) DEFAULT NULL,
  `reviewed_by` int(10) UNSIGNED DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `loans`
--

CREATE TABLE `loans` (
  `id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `loan_number` varchar(30) NOT NULL,
  `loan_product` varchar(100) DEFAULT NULL,
  `loan_amount` decimal(15,2) NOT NULL,
  `remaining_balance` decimal(15,2) NOT NULL,
  `status` enum('pending','approved','rejected','paid') NOT NULL,
  `application_date` date NOT NULL,
  `loan_term` varchar(20) DEFAULT NULL,
  `loan_purpose` text DEFAULT NULL,
  `contact_number` varchar(30) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `civil_status` enum('Single','Married','Widowed','Separated') DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `occupation` varchar(100) DEFAULT NULL,
  `employer` varchar(150) DEFAULT NULL,
  `monthly_income` decimal(15,2) DEFAULT NULL,
  `id_type` varchar(50) DEFAULT NULL,
  `id_number` varchar(100) DEFAULT NULL,
  `id_document_path` varchar(255) DEFAULT NULL,
  `proof_income_path` varchar(255) DEFAULT NULL,
  `identity_status` enum('pending','verified','rejected') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `identity_verified_by` int(10) UNSIGNED DEFAULT NULL,
  `identity_verified_at` datetime DEFAULT NULL,
  `identity_notes` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `members`
--

CREATE TABLE `members` (
  `id` int(11) UNSIGNED NOT NULL,
  `user_id` int(11) UNSIGNED NOT NULL,
  `member_number` varchar(20) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `membership_applications`
--

CREATE TABLE `membership_applications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `member_name` varchar(150) NOT NULL,
  `email` varchar(150) NOT NULL,
  `phone` varchar(30) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `preferred_mode` enum('face_to_face','online','either') DEFAULT NULL,
  `application_reference` varchar(30) DEFAULT NULL,
  `preferred_schedule_date` date DEFAULT NULL,
  `pmes_schedule` varchar(100) DEFAULT NULL,
  `pmes_mode` enum('face_to_face','online') DEFAULT NULL,
  `pmes_location` varchar(255) DEFAULT NULL,
  `pmes_link` varchar(255) DEFAULT NULL,
  `certificate_path` varchar(255) DEFAULT NULL,
  `id_picture_path` varchar(255) DEFAULT NULL,
  `barangay_certificate_path` varchar(255) DEFAULT NULL,
  `birth_certificate_path` varchar(255) DEFAULT NULL,
  `government_id_path` varchar(255) DEFAULT NULL,
  `proof_billing_path` varchar(255) DEFAULT NULL,
  `tin_document_path` varchar(255) DEFAULT NULL,
  `valid_id_path` varchar(255) DEFAULT NULL,
  `proof_address_path` varchar(255) DEFAULT NULL,
  `document_paths` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`document_paths`)),
  `status` enum('pending_schedule','scheduled','pmes_completed','documents_submitted','under_review','approved','rejected') NOT NULL DEFAULT 'pending_schedule',
  `notes` text DEFAULT NULL,
  `admin_notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `transaction_type` enum('deposit','withdrawal','transfer') NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `recipient_account_id` int(10) UNSIGNED DEFAULT NULL,
  `description` varchar(255) NOT NULL,
  `status` enum('pending','completed','failed') NOT NULL,
  `reference_number` varchar(50) NOT NULL,
  `transaction_date` int(11) NOT NULL,
  `created_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('member','admin') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `status` enum('active','inactive') NOT NULL,
  `otp_code` varchar(255) DEFAULT NULL,
  `otp_expires_at` datetime DEFAULT NULL,
  `otp_attempts` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_mfa`
--

CREATE TABLE `user_mfa` (
  `user_id` int(10) UNSIGNED NOT NULL,
  `secret` varchar(255) NOT NULL,
  `last_step` bigint(20) NOT NULL DEFAULT -1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `account_number` (`account_number`),
  ADD KEY `member_id` (`member_id`);

--
-- Indexes for table `account_requests`
--
ALTER TABLE `account_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_account_requests_status` (`status`,`requested_at`),
  ADD KEY `fk_account_requests_member` (`member_id`),
  ADD KEY `fk_account_requests_reviewer` (`reviewed_by`);

--
-- Indexes for table `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_announcements_status_date` (`status`,`published_at`),
  ADD KEY `fk_announcements_user` (`created_by`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `auth_throttle`
--
ALTER TABLE `auth_throttle`
  ADD PRIMARY KEY (`bucket`);

--
-- Indexes for table `deposit_requests`
--
ALTER TABLE `deposit_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_deposit_requests_status` (`status`,`created_at`),
  ADD KEY `fk_deposit_requests_account` (`account_id`),
  ADD KEY `fk_deposit_requests_member` (`member_id`),
  ADD KEY `fk_deposit_requests_reviewer` (`reviewed_by`);

--
-- Indexes for table `loans`
--
ALTER TABLE `loans`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `loan_number` (`loan_number`),
  ADD KEY `member_id` (`member_id`);

--
-- Indexes for table `members`
--
ALTER TABLE `members`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `member_number` (`member_number`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `membership_applications`
--
ALTER TABLE `membership_applications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `application_reference` (`application_reference`),
  ADD KEY `idx_membership_applications_status` (`status`,`created_at`),
  ADD KEY `fk_membership_applications_user` (`user_id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_password_reset_token` (`token_hash`),
  ADD KEY `idx_password_reset_user` (`user_id`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `reference_number` (`reference_number`),
  ADD KEY `account_id` (`account_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `user_mfa`
--
ALTER TABLE `user_mfa`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accounts`
--
ALTER TABLE `accounts`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `account_requests`
--
ALTER TABLE `account_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `announcements`
--
ALTER TABLE `announcements`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `deposit_requests`
--
ALTER TABLE `deposit_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `loans`
--
ALTER TABLE `loans`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `members`
--
ALTER TABLE `members`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `membership_applications`
--
ALTER TABLE `membership_applications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `accounts`
--
ALTER TABLE `accounts`
  ADD CONSTRAINT `fk_accounts_member` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `account_requests`
--
ALTER TABLE `account_requests`
  ADD CONSTRAINT `fk_account_requests_member` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_account_requests_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `announcements`
--
ALTER TABLE `announcements`
  ADD CONSTRAINT `fk_announcements_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `deposit_requests`
--
ALTER TABLE `deposit_requests`
  ADD CONSTRAINT `fk_deposit_requests_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`),
  ADD CONSTRAINT `fk_deposit_requests_member` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`),
  ADD CONSTRAINT `fk_deposit_requests_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `members`
--
ALTER TABLE `members`
  ADD CONSTRAINT `fk_members_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD CONSTRAINT `fk_password_reset_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_mfa`
--
ALTER TABLE `user_mfa`
  ADD CONSTRAINT `fk_mfa_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
SET FOREIGN_KEY_CHECKS=1;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration.sql
-- ============================================================================
ALTER TABLE loans
    ADD COLUMN IF NOT EXISTS loan_product VARCHAR(120) NULL,
    ADD COLUMN IF NOT EXISTS loan_term VARCHAR(30) NULL,
    ADD COLUMN IF NOT EXISTS loan_purpose TEXT NULL,
    ADD COLUMN IF NOT EXISTS contact_number VARCHAR(30) NULL,
    ADD COLUMN IF NOT EXISTS birth_date DATE NULL,
    ADD COLUMN IF NOT EXISTS civil_status VARCHAR(30) NULL,
    ADD COLUMN IF NOT EXISTS address VARCHAR(255) NULL,
    ADD COLUMN IF NOT EXISTS occupation VARCHAR(120) NULL,
    ADD COLUMN IF NOT EXISTS employer VARCHAR(160) NULL,
    ADD COLUMN IF NOT EXISTS monthly_income DECIMAL(15,2) NULL,
    ADD COLUMN IF NOT EXISTS id_type VARCHAR(80) NULL,
    ADD COLUMN IF NOT EXISTS id_number VARCHAR(80) NULL,
    ADD COLUMN IF NOT EXISTS id_document_path VARCHAR(255) NULL,
    ADD COLUMN IF NOT EXISTS proof_income_path VARCHAR(255) NULL,
    ADD COLUMN IF NOT EXISTS identity_status ENUM('pending','verified','rejected') NOT NULL DEFAULT 'pending',
    ADD COLUMN IF NOT EXISTS identity_verified_by INT(10) UNSIGNED NULL,
    ADD COLUMN IF NOT EXISTS identity_verified_at DATETIME NULL,
    ADD COLUMN IF NOT EXISTS identity_notes VARCHAR(500) NULL;

CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    token_hash CHAR(64) NOT NULL,
    expires_at DATETIME NOT NULL,
    used_at DATETIME DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_password_reset_token (token_hash),
    INDEX idx_password_reset_user (user_id),
    CONSTRAINT fk_password_reset_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS deposit_requests (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    account_id INT UNSIGNED NOT NULL,
    member_id INT UNSIGNED NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    payment_method VARCHAR(40) NOT NULL,
    payment_reference VARCHAR(120) NOT NULL,
    description VARCHAR(255) NOT NULL,
    receipt_path VARCHAR(255) NOT NULL,
    status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    admin_notes VARCHAR(500) DEFAULT NULL,
    reviewed_by INT UNSIGNED DEFAULT NULL,
    reviewed_at DATETIME DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_deposit_requests_status (status, created_at),
    CONSTRAINT fk_deposit_requests_account FOREIGN KEY (account_id) REFERENCES accounts(id),
    CONSTRAINT fk_deposit_requests_member FOREIGN KEY (member_id) REFERENCES members(id),
    CONSTRAINT fk_deposit_requests_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: security/schema.sql
-- ============================================================================
CREATE TABLE IF NOT EXISTS deposit_requests (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    account_id INT UNSIGNED NOT NULL,
    member_id INT UNSIGNED NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    payment_method VARCHAR(40) NOT NULL,
    payment_reference VARCHAR(120) NOT NULL,
    description VARCHAR(255) NOT NULL,
    receipt_path VARCHAR(255) NOT NULL,
    status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    admin_notes VARCHAR(500) DEFAULT NULL,
    reviewed_by INT UNSIGNED DEFAULT NULL,
    reviewed_at DATETIME DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_deposit_requests_status (status, created_at),
    CONSTRAINT fk_deposit_requests_account FOREIGN KEY (account_id) REFERENCES accounts(id),
    CONSTRAINT fk_deposit_requests_member FOREIGN KEY (member_id) REFERENCES members(id),
    CONSTRAINT fk_deposit_requests_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS membership_applications (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,

    user_id INT UNSIGNED DEFAULT NULL,

    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    member_name VARCHAR(150) NOT NULL,

    email VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    address VARCHAR(255) NOT NULL,

    preferred_mode ENUM(
        'face_to_face',
        'online',
        'either'
    ) NOT NULL,

    application_reference VARCHAR(30) NOT NULL UNIQUE,

    preferred_schedule_date DATE DEFAULT NULL,
    pmes_schedule VARCHAR(100) DEFAULT NULL,

    pmes_mode ENUM(
        'face_to_face',
        'online'
    ) DEFAULT NULL,

    pmes_location VARCHAR(255) DEFAULT NULL,
    pmes_link VARCHAR(255) DEFAULT NULL,

    certificate_path VARCHAR(255) DEFAULT NULL,
    valid_id_path VARCHAR(255) DEFAULT NULL,
    proof_address_path VARCHAR(255) DEFAULT NULL,

    document_paths JSON DEFAULT NULL,

    status ENUM(
        'pending_schedule',
        'scheduled',
        'documents_submitted',
        'under_review',
        'approved',
        'rejected'
    ) NOT NULL DEFAULT 'pending_schedule',

    notes TEXT DEFAULT NULL,
    admin_notes TEXT DEFAULT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_membership_applications_status (status, created_at),
    INDEX idx_membership_applications_email (email),

    CONSTRAINT fk_membership_applications_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE SET NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS password_reset_tokens (
        id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
        user_id INT UNSIGNED NOT NULL,
        token_hash CHAR(64) NOT NULL,
        expires_at DATETIME NOT NULL,
        used_at DATETIME DEFAULT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_password_reset_token (token_hash),
        INDEX idx_password_reset_user (user_id),
        CONSTRAINT fk_password_reset_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS account_requests (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    member_id INT UNSIGNED NOT NULL,
    account_type VARCHAR(120) NOT NULL,
    status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    admin_notes TEXT DEFAULT NULL,
    requested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_by INT UNSIGNED DEFAULT NULL,
    reviewed_at DATETIME DEFAULT NULL,
    INDEX idx_account_requests_status (status, requested_at),
    CONSTRAINT fk_account_requests_member FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
    CONSTRAINT fk_account_requests_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS announcements (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(160) NOT NULL,
    body TEXT NOT NULL,
    image_path VARCHAR(255) DEFAULT NULL,
    published_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('published','archived') NOT NULL DEFAULT 'published',
    created_by INT UNSIGNED DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_announcements_status_date (status, published_at),
    CONSTRAINT fk_announcements_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_loan_system_step1.sql
-- ============================================================================
-- PASCCO Loan System - Step 1
-- Adds configurable loan products, loan brackets, and payment schedules.
-- Safe design: existing loans and existing loan_product text are preserved.
-- Run this AFTER backing up the database.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS loan_products (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(120) NOT NULL,
    description VARCHAR(500) DEFAULT NULL,
    status ENUM('active','inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_loan_products_name (name),
    KEY idx_loan_products_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS loan_brackets (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    loan_product_id INT UNSIGNED NOT NULL,
    bracket_name VARCHAR(80) NOT NULL,
    minimum_amount DECIMAL(15,2) NOT NULL,
    maximum_amount DECIMAL(15,2) NOT NULL,
    minimum_income DECIMAL(15,2) DEFAULT NULL,
    maximum_income DECIMAL(15,2) DEFAULT NULL,
    term_months INT UNSIGNED NOT NULL,
    interest_rate DECIMAL(7,4) NOT NULL DEFAULT 0.0000,
    interest_method ENUM('flat','reducing_balance') NOT NULL DEFAULT 'flat',
    required_savings DECIMAL(15,2) DEFAULT NULL,
    status ENUM('active','inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_loan_bracket_name (loan_product_id, bracket_name),
    KEY idx_loan_brackets_product_status (loan_product_id, status),
    CONSTRAINT fk_loan_brackets_product
        FOREIGN KEY (loan_product_id) REFERENCES loan_products(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_loan_bracket_amounts CHECK (minimum_amount > 0 AND maximum_amount >= minimum_amount),
    CONSTRAINT chk_loan_bracket_term CHECK (term_months > 0),
    CONSTRAINT chk_loan_bracket_interest CHECK (interest_rate >= 0),
    CONSTRAINT chk_loan_bracket_income CHECK (
        maximum_income IS NULL OR minimum_income IS NULL OR maximum_income >= minimum_income
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Keep the old loan_product text column for backward compatibility, while storing
-- the exact product/bracket used by a new application.
ALTER TABLE loans
    ADD COLUMN IF NOT EXISTS loan_product_id INT UNSIGNED NULL,
    ADD COLUMN IF NOT EXISTS loan_bracket_id INT UNSIGNED NULL,
    ADD COLUMN IF NOT EXISTS interest_rate DECIMAL(7,4) NULL,
    ADD COLUMN IF NOT EXISTS interest_amount DECIMAL(15,2) NULL,
    ADD COLUMN IF NOT EXISTS total_payable DECIMAL(15,2) NULL,
    ADD COLUMN IF NOT EXISTS monthly_payment DECIMAL(15,2) NULL,
    ADD COLUMN IF NOT EXISTS approval_date DATETIME NULL,
    ADD COLUMN IF NOT EXISTS approved_by INT UNSIGNED NULL,
    ADD COLUMN IF NOT EXISTS rejection_reason VARCHAR(500) NULL,
    ADD COLUMN IF NOT EXISTS disbursement_date DATETIME NULL,
    ADD COLUMN IF NOT EXISTS maturity_date DATE NULL;

ALTER TABLE loans
    MODIFY COLUMN status ENUM('pending','under_review','approved','disbursed','active','rejected','paid') NOT NULL DEFAULT 'pending';

SET @loan_product_fk_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'loans'
      AND CONSTRAINT_NAME = 'fk_loans_product'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql := IF(
    @loan_product_fk_exists = 0,
    'ALTER TABLE loans ADD CONSTRAINT fk_loans_product FOREIGN KEY (loan_product_id) REFERENCES loan_products(id) ON UPDATE CASCADE ON DELETE RESTRICT',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @loan_bracket_fk_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'loans'
      AND CONSTRAINT_NAME = 'fk_loans_bracket'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql := IF(
    @loan_bracket_fk_exists = 0,
    'ALTER TABLE loans ADD CONSTRAINT fk_loans_bracket FOREIGN KEY (loan_bracket_id) REFERENCES loan_brackets(id) ON UPDATE CASCADE ON DELETE RESTRICT',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @loan_approved_by_fk_exists := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'loans'
      AND CONSTRAINT_NAME = 'fk_loans_approved_by'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql := IF(
    @loan_approved_by_fk_exists = 0,
    'ALTER TABLE loans ADD CONSTRAINT fk_loans_approved_by FOREIGN KEY (approved_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @loan_product_idx_exists := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'loans' AND INDEX_NAME = 'idx_loans_product'
);
SET @sql := IF(
    @loan_product_idx_exists = 0,
    'ALTER TABLE loans ADD INDEX idx_loans_product (loan_product_id)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @loan_bracket_idx_exists := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'loans' AND INDEX_NAME = 'idx_loans_bracket'
);
SET @sql := IF(
    @loan_bracket_idx_exists = 0,
    'ALTER TABLE loans ADD INDEX idx_loans_bracket (loan_bracket_id)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CREATE TABLE IF NOT EXISTS loan_payments (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    loan_id INT(11) NOT NULL,
    payment_number INT UNSIGNED NOT NULL,
    due_date DATE NOT NULL,
    amount_due DECIMAL(15,2) NOT NULL,
    amount_paid DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    payment_date DATETIME DEFAULT NULL,
    status ENUM('scheduled','partial','paid','overdue','waived') NOT NULL DEFAULT 'scheduled',
    reference_number VARCHAR(60) DEFAULT NULL,
    notes VARCHAR(500) DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_loan_payment_number (loan_id, payment_number),
    UNIQUE KEY uq_loan_payment_reference (reference_number),
    KEY idx_loan_payments_due (loan_id, due_date, status),
    CONSTRAINT fk_loan_payments_loan
        FOREIGN KEY (loan_id) REFERENCES loans(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_loan_payment_amounts CHECK (amount_due > 0 AND amount_paid >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed only the product names already supported by the current application.
-- No financial bracket values are invented here; Step 2 will configure them.
INSERT INTO loan_products (name, status)
VALUES
('Business Loan','active'),
('Special Promo Loan','active'),
('Livelihood Loan','active'),
('Quick Loan - Productive','active'),
('Collateralized Loan','active'),
('Calamity Loan','active'),
('Educational / Tuition Loan','active'),
('Medical / Dental Loan','active'),
('Quick Loan - Providential','active'),
('Minor Home Improvement Loan','active'),
('Petty Cash Loan','active'),
('Multipurpose Loan','active'),
('Easyoperability Gadgets Loan','active'),
('Easyoperability BHK Loan','active'),
('Easyoperability Optical Loan','active'),
('Health & Wellness Loan','active'),
('Memorial Plan','active'),
('Personal Accident Insurance','active'),
('Manila North Green Park','active'),
('Special Loan','active')
ON DUPLICATE KEY UPDATE status = VALUES(status);

COMMIT;

-- IMPORTANT:
-- Do not fill loan brackets until the cooperative's actual rules are known.
-- Step 2 will add the approved amount ranges, income requirements, terms,
-- interest rates, and savings requirements for each loan product.


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_loan_system_step2.sql
-- ============================================================================
-- PASCCO Loan System - Step 2
-- Adds an explicit interest-rate basis so loan calculations are not ambiguous.
-- This does NOT invent PASCCO financial policies. Administrators must enter the
-- cooperative-approved bracket values through the Loan Products page.

START TRANSACTION;

ALTER TABLE loan_brackets
    ADD COLUMN IF NOT EXISTS interest_rate_basis ENUM('annual','term') NOT NULL DEFAULT 'annual' AFTER interest_rate;

COMMIT;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_loan_system_step3.sql
-- ============================================================================
-- PASCCO Loan System - Step 3
-- Loan servicing: payment allocation history and reliable overdue tracking.
-- Run AFTER Step 1 and Step 2, and only after taking a database backup.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS loan_payment_allocations (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    loan_id INT(11) NOT NULL,
    loan_payment_id BIGINT UNSIGNED NOT NULL,
    reference_number VARCHAR(60) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_by INT UNSIGNED DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_loan_allocations_loan (loan_id, payment_date),
    KEY idx_loan_allocations_schedule (loan_payment_id, payment_date),
    KEY idx_loan_allocations_reference (reference_number),
    CONSTRAINT chk_loan_allocation_amount CHECK (amount > 0),
    CONSTRAINT fk_loan_allocations_loan
        FOREIGN KEY (loan_id) REFERENCES loans(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_loan_allocations_payment
        FOREIGN KEY (loan_payment_id) REFERENCES loan_payments(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_loan_allocations_user
        FOREIGN KEY (processed_by) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE loans
    ADD COLUMN IF NOT EXISTS last_payment_date DATETIME NULL,
    ADD COLUMN IF NOT EXISTS next_due_date DATE NULL;

SET @loan_due_idx_exists := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'loans' AND INDEX_NAME = 'idx_loans_status_due'
);
SET @sql := IF(
    @loan_due_idx_exists = 0,
    'CREATE INDEX idx_loans_status_due ON loans(status, next_due_date)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

COMMIT;

-- Step 3 intentionally does not seed financial values or alter PASCCO rates.


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_loan_system_step4.sql
-- ============================================================================
-- PASCCO Loan System - Step 4
-- Controlled recording of external/manual loan payments.
-- Run AFTER Step 1, Step 2, and Step 3, and only after taking a database backup.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS loan_payment_receipts (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    loan_id INT(11) NOT NULL,
    receipt_number VARCHAR(60) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    external_reference VARCHAR(100) DEFAULT NULL,
    notes VARCHAR(500) DEFAULT NULL,
    received_by INT UNSIGNED DEFAULT NULL,
    received_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_loan_receipt_number (receipt_number),
    KEY idx_loan_receipts_loan (loan_id, received_at),
    KEY idx_loan_receipts_reference (external_reference),
    CONSTRAINT chk_loan_receipt_amount CHECK (amount > 0),
    CONSTRAINT fk_loan_receipts_loan
        FOREIGN KEY (loan_id) REFERENCES loans(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_loan_receipts_user
        FOREIGN KEY (received_by) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

COMMIT;

-- Step 4 intentionally does not seed financial values or alter PASCCO rates.


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_loan_system_step5.sql
-- ============================================================================
-- PASCCO Loan System - Step 5
-- Reporting performance indexes only; no financial data or policy changes.
-- Run AFTER Steps 1 through 4 and after taking a database backup.

START TRANSACTION;

SET @idx_alloc_date_exists := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'loan_payment_allocations' AND INDEX_NAME = 'idx_loan_allocations_payment_date'
);
SET @sql := IF(@idx_alloc_date_exists = 0,
    'CREATE INDEX idx_loan_allocations_payment_date ON loan_payment_allocations(payment_date)',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_receipt_date_exists := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'loan_payment_receipts' AND INDEX_NAME = 'idx_loan_receipts_received_at'
);
SET @sql := IF(@idx_receipt_date_exists = 0,
    'CREATE INDEX idx_loan_receipts_received_at ON loan_payment_receipts(received_at)',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

COMMIT;

-- This migration does not alter loan balances, schedules, rates, or receipts.


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_loan_system_step6.sql
-- ============================================================================
-- PASCCO Loan System Step 6
-- Loan due-date and overdue notification tracking.
-- This migration does not alter loan balances, rates, schedules, or payment amounts.

CREATE TABLE IF NOT EXISTS loan_notification_logs (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    loan_id INT(11) NOT NULL,
    member_id INT UNSIGNED NOT NULL,
    notification_type VARCHAR(40) NOT NULL,
    reference_date DATE NOT NULL,
    recipient_email VARCHAR(150) NOT NULL,
    status ENUM('sent','failed') NOT NULL,
    error_message VARCHAR(500) DEFAULT NULL,
    sent_at DATETIME DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_loan_notification (loan_id, notification_type, reference_date),
    INDEX idx_loan_notification_status_date (status, created_at),
    INDEX idx_loan_notification_member (member_id, created_at),
    CONSTRAINT fk_loan_notification_loan FOREIGN KEY (loan_id) REFERENCES loans(id) ON DELETE CASCADE,
    CONSTRAINT fk_loan_notification_member FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

START TRANSACTION;

SET @idx_loans_notification_due_exists := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'loans' AND INDEX_NAME = 'idx_loans_notification_due'
);
SET @sql := IF(@idx_loans_notification_due_exists = 0,
    'CREATE INDEX idx_loans_notification_due ON loans(status, next_due_date, member_id)',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

COMMIT;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_loan_system_step7.sql
-- ============================================================================
-- PASCCO Loan System Step 7 — Multi-Stage Loan Approval Workflow
-- Adds a two-admin approval workflow without changing financial policies.
-- Apply after database_migration_loan_system_step6.sql.

ALTER TABLE loans
    ADD COLUMN IF NOT EXISTS required_approvals TINYINT UNSIGNED NOT NULL DEFAULT 2,
    ADD COLUMN IF NOT EXISTS committee_submitted_at DATETIME NULL,
    ADD COLUMN IF NOT EXISTS committee_completed_at DATETIME NULL;

SET @loan_committee_index_exists := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'loans'
      AND INDEX_NAME = 'idx_loans_committee_status'
);
SET @sql := IF(
    @loan_committee_index_exists = 0,
    'ALTER TABLE loans ADD INDEX idx_loans_committee_status (status, committee_submitted_at)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CREATE TABLE IF NOT EXISTS loan_approval_reviews (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    reviewer_id INT UNSIGNED NOT NULL,
    decision ENUM('approved','rejected') NOT NULL,
    notes VARCHAR(500) DEFAULT NULL,
    reviewed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_loan_reviewer (loan_id, reviewer_id),
    INDEX idx_loan_reviews_loan (loan_id, reviewed_at),
    INDEX idx_loan_reviews_reviewer (reviewer_id, reviewed_at),
    CONSTRAINT fk_loan_reviews_loan FOREIGN KEY (loan_id) REFERENCES loans(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_loan_reviews_reviewer FOREIGN KEY (reviewer_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_loan_system_step8.sql
-- ============================================================================
-- PASCCO Loan System Step 8 — Loan Statements and Payment Documents
-- Adds supporting indexes for statement and receipt lookups only.
-- Apply after database_migration_loan_system_step7.sql.

SET @idx_alloc_exists := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'loan_payment_allocations'
      AND INDEX_NAME = 'idx_loan_alloc_statement'
);
SET @sql := IF(
    @idx_alloc_exists = 0,
    'ALTER TABLE loan_payment_allocations ADD INDEX idx_loan_alloc_statement (loan_id, payment_date, id)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_receipt_exists := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'loan_payment_receipts'
      AND INDEX_NAME = 'idx_loan_receipts_statement'
);
SET @sql := IF(
    @idx_receipt_exists = 0,
    'ALTER TABLE loan_payment_receipts ADD INDEX idx_loan_receipts_statement (loan_id, received_at, id)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_loan_system_step9.sql
-- ============================================================================
-- PASCCO Loan System Step 9 — Loan Closure and Clearance
-- Adds a formal closure record for fully paid loans without changing the existing loan status model.
-- Apply after database_migration_loan_system_step8.sql.

CREATE TABLE IF NOT EXISTS loan_closures (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    closure_reference VARCHAR(60) NOT NULL,
    cleared_by INT UNSIGNED NOT NULL,
    cleared_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes VARCHAR(500) DEFAULT NULL,
    UNIQUE KEY uq_loan_closure_loan (loan_id),
    UNIQUE KEY uq_loan_closure_reference (closure_reference),
    INDEX idx_loan_closures_date (cleared_at, id),
    CONSTRAINT fk_loan_closures_loan FOREIGN KEY (loan_id) REFERENCES loans(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_loan_closures_user FOREIGN KEY (cleared_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_loan_system_step10.sql
-- ============================================================================
-- PASCCO Loan System Step 10
-- Delinquency and collection follow-up notes.
-- This migration does not change balances, schedules, or loan status.

CREATE TABLE IF NOT EXISTS loan_collection_notes (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    loan_id INT NOT NULL,
    contact_date DATE NOT NULL,
    contact_method VARCHAR(40) NOT NULL,
    outcome VARCHAR(100) NOT NULL,
    promise_date DATE NULL,
    promise_amount DECIMAL(15,2) NULL,
    notes TEXT NULL,
    created_by INT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_collection_notes_loan_date (loan_id, contact_date),
    KEY idx_collection_notes_promise_date (promise_date),
    CONSTRAINT fk_collection_notes_loan FOREIGN KEY (loan_id) REFERENCES loans(id) ON DELETE CASCADE,
    CONSTRAINT fk_collection_notes_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_loan_system_step11.sql
-- ============================================================================
-- PASCCO Loan System Step 11
-- Controlled loan restructuring request and review workflow.
-- This migration does NOT modify loan balances, repayment schedules, interest, or status.

CREATE TABLE IF NOT EXISTS loan_restructuring_requests (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    loan_id INT NOT NULL,
    requested_by INT UNSIGNED NOT NULL,
    reason VARCHAR(500) NOT NULL,
    proposed_term_months INT UNSIGNED NULL,
    proposed_monthly_payment DECIMAL(15,2) NULL,
    proposed_total_payable DECIMAL(15,2) NULL,
    proposed_effective_date DATE NULL,
    status ENUM('pending','approved','rejected','cancelled') NOT NULL DEFAULT 'pending',
    submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME NULL,
    completed_by INT UNSIGNED NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_restructure_loan_status (loan_id, status),
    KEY idx_restructure_status_date (status, submitted_at),
    CONSTRAINT fk_restructure_loan FOREIGN KEY (loan_id) REFERENCES loans(id) ON DELETE CASCADE,
    CONSTRAINT fk_restructure_requested_by FOREIGN KEY (requested_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_restructure_completed_by FOREIGN KEY (completed_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS loan_restructuring_reviews (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    restructuring_request_id INT UNSIGNED NOT NULL,
    reviewer_id INT UNSIGNED NOT NULL,
    decision ENUM('approved','rejected') NOT NULL,
    notes VARCHAR(500) NULL,
    reviewed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_restructure_reviewer (restructuring_request_id, reviewer_id),
    KEY idx_restructure_reviews_request_decision (restructuring_request_id, decision),
    CONSTRAINT fk_restructure_review_request FOREIGN KEY (restructuring_request_id) REFERENCES loan_restructuring_requests(id) ON DELETE CASCADE,
    CONSTRAINT fk_restructure_review_user FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_loan_system_step12.sql
-- ============================================================================
-- PASCCO Loan System Step 12
-- Controlled execution of an approved restructuring proposal.
-- This creates an immutable execution snapshot and replaces only unpaid schedule rows.
-- Import AFTER Step 11 and only after taking a database backup.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS loan_restructuring_executions (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    restructuring_request_id INT UNSIGNED NOT NULL,
    loan_id INT NOT NULL,
    execution_reference VARCHAR(80) NOT NULL,
    executed_by INT UNSIGNED NOT NULL,
    effective_date DATE NOT NULL,
    previous_total_payable DECIMAL(15,2) NULL,
    previous_remaining_balance DECIMAL(15,2) NOT NULL,
    previous_monthly_payment DECIMAL(15,2) NULL,
    previous_term_months INT UNSIGNED NULL,
    new_total_payable DECIMAL(15,2) NOT NULL,
    new_remaining_balance DECIMAL(15,2) NOT NULL,
    new_monthly_payment DECIMAL(15,2) NOT NULL,
    new_term_months INT UNSIGNED NOT NULL,
    new_maturity_date DATE NOT NULL,
    executed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_restructure_execution_request (restructuring_request_id),
    UNIQUE KEY uq_restructure_execution_reference (execution_reference),
    KEY idx_restructure_execution_loan (loan_id, executed_at),
    CONSTRAINT fk_restructure_execution_request FOREIGN KEY (restructuring_request_id) REFERENCES loan_restructuring_requests(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_restructure_execution_loan FOREIGN KEY (loan_id) REFERENCES loans(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_restructure_execution_user FOREIGN KEY (executed_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET @restructure_idx_exists := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'loan_payments' AND INDEX_NAME = 'idx_loan_payments_restructure'
);
SET @sql := IF(
    @restructure_idx_exists = 0,
    'CREATE INDEX idx_loan_payments_restructure ON loan_payments(loan_id, status, payment_number)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

COMMIT;

-- Step 12 does not invent rates, fees, waivers, or restructuring policy.
-- The approved Step 11 proposal supplies the new remaining payable, term, monthly payment, and effective date.


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_loan_system_final_single_admin.sql
-- ============================================================================
-- PASCCO Loan System Final Correction — Single Administrator Approval Model
-- Apply AFTER database_migration_loan_system_step12.sql.
-- Aligns the existing loan workflow with PASCCO's current one-admin setup.
-- No financial transactions are created, deleted, or changed by this migration.

START TRANSACTION;

UPDATE loans
SET required_approvals = 1
WHERE required_approvals IS NULL OR required_approvals <> 1;

ALTER TABLE loans
    ALTER COLUMN required_approvals SET DEFAULT 1;

COMMIT;

-- The application layer also enforces one required approval.
-- Restructuring review/execution is single-admin in the current setup.


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_announcements_audience.sql
-- ============================================================================
-- PASCCO Announcement Audience Control
-- Adds a destination/audience to announcements so administrators can choose
-- whether an announcement is shown publicly, to members, or to both.
--
-- Run once on the existing paco_cooperative database. Back up first.
-- Safe to re-run: the column/index are checked before creation.

SET @column_exists := (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'announcements'
      AND COLUMN_NAME = 'audience'
);

SET @sql := IF(
    @column_exists = 0,
    "ALTER TABLE announcements ADD COLUMN audience ENUM('public','members','both') NOT NULL DEFAULT 'members' AFTER image_path",
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Preserve existing published announcements in both destinations so no
-- existing announcement disappears from either audience after the upgrade.
UPDATE announcements
SET audience = 'both'
WHERE status = 'published';

SET @index_exists := (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'announcements'
      AND INDEX_NAME = 'idx_announcements_audience_status_date'
);

SET @sql := IF(
    @index_exists = 0,
    'CREATE INDEX idx_announcements_audience_status_date ON announcements (audience, status, published_at)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_settings_phase1.sql
-- ============================================================================
-- PASCCO Settings Foundation - Phase 1
-- Import this migration once into the existing paco_cooperative database.
-- Safe to re-run: CREATE TABLE IF NOT EXISTS and INSERT IGNORE are used.

CREATE TABLE IF NOT EXISTS member_settings (
    user_id INT UNSIGNED NOT NULL,
    theme ENUM('light', 'dark', 'system') NOT NULL DEFAULT 'light',
    text_size ENUM('small', 'medium', 'large') NOT NULL DEFAULT 'medium',
    language_code VARCHAR(10) NOT NULL DEFAULT 'en',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    CONSTRAINT fk_member_settings_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed settings for existing accounts. New member rows are created lazily by settings.php.
INSERT IGNORE INTO member_settings (user_id)
SELECT id FROM users;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_settings_phase3_password_management.sql
-- ============================================================================
-- PASCCO Settings Phase 3: Password Management
-- No new tables are required. This phase hardens the existing users.password
-- and password_reset_tokens workflow and adds the authenticated member
-- change-password page.
--
-- IMPORTANT: Do not import previous PASCCO migrations again.
-- This file is intentionally a documentation marker for Phase 3 and is safe
-- to import because it contains no schema-changing statements.

SELECT 'PASCCO Settings Phase 3 password management requires no schema migration.' AS status;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_settings_phase4_mfa.sql
-- ============================================================================
-- PASCCO Settings Phase 4: MFA Settings
-- No new schema is required. The existing user_mfa table stores encrypted
-- authenticator secrets and is now also used for member authenticator MFA.
SELECT 'Settings Phase 4 requires no schema migration.' AS status;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_settings_phase5_active_sessions.sql
-- ============================================================================
-- PASCCO Settings Phase 5: Active Sessions / Devices
-- Import this migration once. It does not modify existing account balances or transactions.

CREATE TABLE IF NOT EXISTS user_sessions (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id INT UNSIGNED NOT NULL,
    session_hash CHAR(64) NOT NULL,
    role VARCHAR(20) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    user_agent VARCHAR(500) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_activity_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revoked_at DATETIME NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_user_sessions_hash (session_hash),
    KEY idx_user_sessions_user (user_id),
    KEY idx_user_sessions_user_active (user_id, revoked_at, last_activity_at),
    CONSTRAINT fk_user_sessions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SELECT 'PASCCO Settings Phase 5 migration ready.' AS status;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_settings_phase6_login_history.sql
-- ============================================================================
-- PASCCO Settings Phase 6: Login History
-- No schema change is required. This phase reuses the existing audit_logs table.
-- Import is not required.
SELECT 'PASCCO Settings Phase 6 requires no schema migration.' AS status;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_settings_phase7_notifications.sql
-- ============================================================================
-- PASCCO Settings Phase 7 - Notification Preferences
-- Import once into the existing paco_cooperative database.
-- Safe to re-run: CREATE TABLE IF NOT EXISTS and INSERT IGNORE are used.

CREATE TABLE IF NOT EXISTS member_notification_preferences (
    user_id INT UNSIGNED NOT NULL,
    loan_payment_reminders TINYINT(1) NOT NULL DEFAULT 1,
    announcements TINYINT(1) NOT NULL DEFAULT 1,
    general_updates TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    CONSTRAINT fk_member_notification_preferences_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO member_notification_preferences (user_id)
SELECT id FROM users;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_settings_phase8_notification_channels.sql
-- ============================================================================
-- PASCCO Settings Phase 8 - Notification Channels
-- Import once into the existing paco_cooperative database.
-- Safe to re-run.

ALTER TABLE member_notification_preferences
    ADD COLUMN IF NOT EXISTS email_notifications TINYINT(1) NOT NULL DEFAULT 1 AFTER general_updates;

-- Existing members remain opted in to the currently supported email channel.
UPDATE member_notification_preferences
SET email_notifications = 1
WHERE email_notifications IS NULL;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_settings_phase9_privacy.sql
-- ============================================================================
-- PASCCO Settings Phase 9 - Privacy Controls & Notice Acknowledgment
-- Import once after the Phase 7/8 notification migrations.

CREATE TABLE IF NOT EXISTS member_privacy_acknowledgments (
    user_id INT UNSIGNED NOT NULL,
    notice_version VARCHAR(40) NOT NULL,
    acknowledged_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    CONSTRAINT fk_member_privacy_ack_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_member_privacy_ack_version (notice_version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_account_number_hardening_step14.sql
-- ============================================================================
-- PASCCO Step 14: Account Number Hardening
-- Purpose:
--   1. Prevent duplicate account_number values at the database level.
--   2. Refuse the migration instead of silently changing existing duplicate data.
--
-- No account balances, account numbers, or transaction records are modified.

DROP PROCEDURE IF EXISTS pascco_enforce_unique_account_number;

DELIMITER $$

CREATE PROCEDURE pascco_enforce_unique_account_number()
BEGIN
    DECLARE duplicate_count INT DEFAULT 0;
    DECLARE unique_index_count INT DEFAULT 0;

    SELECT COUNT(*)
      INTO duplicate_count
      FROM (
          SELECT account_number
          FROM accounts
          GROUP BY account_number
          HAVING COUNT(*) > 1
      ) AS duplicates;

    IF duplicate_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Step 14 stopped: duplicate account_number values already exist. Review and resolve those records before adding the unique constraint.';
    END IF;

    SELECT COUNT(*)
      INTO unique_index_count
      FROM information_schema.statistics
     WHERE table_schema = DATABASE()
       AND table_name = 'accounts'
       AND column_name = 'account_number'
       AND non_unique = 0;

    IF unique_index_count = 0 THEN
        SET @pascco_add_account_number_unique = 'ALTER TABLE accounts ADD UNIQUE KEY uq_accounts_account_number (account_number)';
        PREPARE pascco_add_account_number_unique_stmt FROM @pascco_add_account_number_unique;
        EXECUTE pascco_add_account_number_unique_stmt;
        DEALLOCATE PREPARE pascco_add_account_number_unique_stmt;
    END IF;
END$$

DELIMITER ;

CALL pascco_enforce_unique_account_number();
DROP PROCEDURE IF EXISTS pascco_enforce_unique_account_number;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_financial_idempotency_step15.sql
-- ============================================================================
-- PASCCO Step 15 - Financial Action Idempotency
-- Prevents repeated browser submissions from creating duplicate financial effects.
-- Run this AFTER Step 14 and after taking a database backup.

START TRANSACTION;

ALTER TABLE transactions
    ADD COLUMN IF NOT EXISTS idempotency_key CHAR(64) NULL;

ALTER TABLE deposit_requests
    ADD COLUMN IF NOT EXISTS idempotency_key CHAR(64) NULL;

ALTER TABLE loan_payment_receipts
    ADD COLUMN IF NOT EXISTS idempotency_key CHAR(64) NULL;

SET @idx_exists := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'transactions' AND INDEX_NAME = 'uq_transactions_idempotency_key'
);
SET @sql := IF(@idx_exists = 0,
    'ALTER TABLE transactions ADD UNIQUE KEY uq_transactions_idempotency_key (idempotency_key)',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx_exists := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'deposit_requests' AND INDEX_NAME = 'uq_deposit_requests_idempotency_key'
);
SET @sql := IF(@idx_exists = 0,
    'ALTER TABLE deposit_requests ADD UNIQUE KEY uq_deposit_requests_idempotency_key (idempotency_key)',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx_exists := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'loan_payment_receipts' AND INDEX_NAME = 'uq_loan_receipts_idempotency_key'
);
SET @sql := IF(@idx_exists = 0,
    'ALTER TABLE loan_payment_receipts ADD UNIQUE KEY uq_loan_receipts_idempotency_key (idempotency_key)',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

COMMIT;


-- ============================================================================
-- INCLUDED FEATURE MIGRATION: database_migration_membership_hardening_step16.sql
-- ============================================================================
-- PASCCO Step 16 - Membership Data Hardening
-- Adds database-level uniqueness for user/member email addresses.
-- Run AFTER Step 15 and after taking a database backup.
--
-- IMPORTANT:
-- The duplicate checks below are read-only. If either query returns rows,
-- resolve those existing duplicates first. The corresponding ALTER TABLE will
-- then fail rather than silently modifying existing records.

-- PRE-FLIGHT: users with duplicate email addresses
SELECT LOWER(TRIM(email)) AS email, COUNT(*) AS duplicate_count
FROM users
WHERE email IS NOT NULL AND TRIM(email) <> ''
GROUP BY LOWER(TRIM(email))
HAVING COUNT(*) > 1;

-- PRE-FLIGHT: members with duplicate email addresses
SELECT LOWER(TRIM(email)) AS email, COUNT(*) AS duplicate_count
FROM members
WHERE email IS NOT NULL AND TRIM(email) <> ''
GROUP BY LOWER(TRIM(email))
HAVING COUNT(*) > 1;

SET @idx_exists := (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'users'
      AND INDEX_NAME = 'uq_users_email'
);
SET @sql := IF(
    @idx_exists = 0,
    'ALTER TABLE users ADD UNIQUE KEY uq_users_email (email)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_exists := (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'members'
      AND INDEX_NAME = 'uq_members_email'
);
SET @sql := IF(
    @idx_exists = 0,
    'ALTER TABLE members ADD UNIQUE KEY uq_members_email (email)',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- INTEGRATED PHASE 1: WITHDRAWAL REQUEST / ADMIN REVIEW WORKFLOW
-- Required by member/dashboard.php, admin/admin_withdrawals.php, and admin reports.
-- ============================================================================
CREATE TABLE IF NOT EXISTS withdrawal_requests (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    account_id INT UNSIGNED NOT NULL,
    member_id INT UNSIGNED NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    description VARCHAR(255) NOT NULL,
    status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    idempotency_key CHAR(64) NOT NULL,
    admin_notes VARCHAR(500) DEFAULT NULL,
    reviewed_by INT UNSIGNED DEFAULT NULL,
    reviewed_at DATETIME DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_withdrawal_requests_idempotency_key (idempotency_key),
    KEY idx_withdrawal_requests_status (status, created_at),
    KEY idx_withdrawal_requests_member (member_id, created_at),
    CONSTRAINT fk_withdrawal_requests_account FOREIGN KEY (account_id) REFERENCES accounts(id),
    CONSTRAINT fk_withdrawal_requests_member FOREIGN KEY (member_id) REFERENCES members(id),
    CONSTRAINT fk_withdrawal_requests_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_withdrawal_requests_amount CHECK (amount > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- INTEGRATED PHASE 5: MIGRATION TRACKING TABLE
-- This table starts empty; mark a migration as applied only after verifying it.
-- The tracker records status; it does not execute SQL migration files.
-- ============================================================================
CREATE TABLE IF NOT EXISTS schema_migrations (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    migration_name VARCHAR(255) NOT NULL,
    checksum_sha256 CHAR(64) NOT NULL,
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    applied_by VARCHAR(100) NOT NULL DEFAULT 'manual',
    notes VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_schema_migrations_name (migration_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS=1;
-- End of PASCCO integrated clean-install SQL.

-- Wedding BnB Database Schema (DDL)
-- Database: 5033_ali
-- Created: November 26, 2025
-- Description: Schema creation for MVP Core Entities

-- ============================================================
-- CREATE DATABASE (if not exists) AND USE IT
-- ============================================================
CREATE DATABASE IF NOT EXISTS 5033_ali
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE 5033_ali;

-- ============================================================
-- DROP EXISTING TABLES (if any) - Uncomment to reset schema
-- ============================================================
DROP TABLE IF EXISTS ROOMAMENITIES;
DROP TABLE IF EXISTS HOTELAMENITIES;
DROP TABLE IF EXISTS PAYMENT;
DROP TABLE IF EXISTS REVIEW;
DROP TABLE IF EXISTS GUESTINFO;
DROP TABLE IF EXISTS BOOKING;
DROP TABLE IF EXISTS AVAILABILITY;
DROP TABLE IF EXISTS AMENITIES;
DROP TABLE IF EXISTS ROOM;
DROP TABLE IF EXISTS HOTEL;
DROP TABLE IF EXISTS USER;

-- ============================================================
-- TABLE 1: USER
-- ============================================================
CREATE TABLE IF NOT EXISTS `USER` (
  UserID INT AUTO_INCREMENT PRIMARY KEY,
  Email VARCHAR(255) UNIQUE NOT NULL,
  Password VARCHAR(255) NOT NULL,
  FirstName VARCHAR(100) NOT NULL,
  LastName VARCHAR(100) NOT NULL,
  PhoneNumber VARCHAR(20),
  Address TEXT,
  City VARCHAR(100),
  State VARCHAR(100),
  PostalCode VARCHAR(20),
  Country VARCHAR(100),
  Role ENUM('Couple', 'Planner', 'HotelAdmin', 'SystemAdmin') NOT NULL,
  AccountStatus ENUM('Active', 'Inactive', 'Suspended') NOT NULL DEFAULT 'Active',
  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  LastLogin DATETIME,
  UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_email (Email),
  INDEX idx_role (Role),
  INDEX idx_accountStatus (AccountStatus),
  INDEX idx_createdAt (CreatedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE 2: HOTEL
-- ============================================================
CREATE TABLE IF NOT EXISTS HOTEL (
  HotelID INT AUTO_INCREMENT PRIMARY KEY,
  HotelName VARCHAR(255) NOT NULL,
  StreetAddress VARCHAR(255) NOT NULL,
  City VARCHAR(100) NOT NULL,
  State VARCHAR(100) NOT NULL,
  PostalCode VARCHAR(20),
  Country VARCHAR(100) NOT NULL,
  PhoneNumber VARCHAR(20),
  Email VARCHAR(255),
  Website VARCHAR(255),
  Description TEXT,
  AverageRating DECIMAL(3,2),
  StarRating INT,
  TotalRooms INT,
  CheckInTime TIME,
  CheckOutTime TIME,
  ImageURL TEXT,
  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_city (City),
  INDEX idx_country (Country),
  INDEX idx_starRating (StarRating),
  INDEX idx_averageRating (AverageRating),
  INDEX idx_createdAt (CreatedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE 3: AMENITIES (Master Data)
-- ============================================================
CREATE TABLE IF NOT EXISTS AMENITIES (
  AmenityID INT AUTO_INCREMENT PRIMARY KEY,
  AmenityName VARCHAR(100) UNIQUE NOT NULL,
  AmenityCategory ENUM('Facility', 'Service', 'Comfort', 'Safety', 'Entertainment') NOT NULL,
  Description TEXT,
  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_amenityName (AmenityName),
  INDEX idx_category (AmenityCategory)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE 4: ROOM
-- ============================================================
CREATE TABLE IF NOT EXISTS ROOM (
  RoomID INT AUTO_INCREMENT PRIMARY KEY,
  HotelID INT NOT NULL,
  RoomNumber VARCHAR(50) NOT NULL,
  RoomType ENUM('Single', 'Double', 'Suite', 'Deluxe', 'Presidential') NOT NULL,
  GuestCapacity INT NOT NULL,
  BedConfiguration VARCHAR(100),
  BasePrice DECIMAL(10,2) NOT NULL,
  RoomStatus ENUM('Available', 'Occupied', 'Maintenance', 'Reserved') NOT NULL DEFAULT 'Available',
  ImageURL TEXT,
  Description TEXT,
  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (HotelID) REFERENCES HOTEL(HotelID) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY uk_hotel_roomNumber (HotelID, RoomNumber),
  INDEX idx_hotelID (HotelID),
  INDEX idx_roomType (RoomType),
  INDEX idx_guestCapacity (GuestCapacity),
  INDEX idx_basePrice (BasePrice),
  INDEX idx_roomStatus (RoomStatus)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE 5: HOTELAMENITIES (Junction Table - Many-to-Many)
-- ============================================================
CREATE TABLE IF NOT EXISTS HOTELAMENITIES (
  HotelAmenityID INT AUTO_INCREMENT PRIMARY KEY,
  HotelID INT NOT NULL,
  AmenityID INT NOT NULL,
  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (HotelID) REFERENCES HOTEL(HotelID) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (AmenityID) REFERENCES AMENITIES(AmenityID) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY uk_hotel_amenity (HotelID, AmenityID),
  INDEX idx_hotelID (HotelID),
  INDEX idx_amenityID (AmenityID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE 6: ROOMAMENITIES (Junction Table - Many-to-Many)
-- ============================================================
CREATE TABLE IF NOT EXISTS ROOMAMENITIES (
  RoomAmenityID INT AUTO_INCREMENT PRIMARY KEY,
  RoomID INT NOT NULL,
  AmenityID INT NOT NULL,
  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (RoomID) REFERENCES ROOM(RoomID) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (AmenityID) REFERENCES AMENITIES(AmenityID) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY uk_room_amenity (RoomID, AmenityID),
  INDEX idx_roomID (RoomID),
  INDEX idx_amenityID (AmenityID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE 7: AVAILABILITY
-- ============================================================
CREATE TABLE IF NOT EXISTS AVAILABILITY (
  AvailabilityID INT AUTO_INCREMENT PRIMARY KEY,
  RoomID INT NOT NULL,
  AvailableDate DATE NOT NULL,
  AvailableRoomsCount INT NOT NULL,
  IsBooked BOOLEAN NOT NULL DEFAULT FALSE,
  PriceOverride DECIMAL(10,2),
  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (RoomID) REFERENCES ROOM(RoomID) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY uk_room_date (RoomID, AvailableDate),
  INDEX idx_roomID (RoomID),
  INDEX idx_availableDate (AvailableDate),
  INDEX idx_isBooked (IsBooked)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLE 8: BOOKING
-- ============================================================
CREATE TABLE IF NOT EXISTS BOOKING (
  BookingID INT AUTO_INCREMENT PRIMARY KEY,
  UserID INT NOT NULL,
  HotelID INT NOT NULL,
  RoomID INT DEFAULT NULL,
  CheckInDate DATE NOT NULL,
  CheckOutDate DATE NOT NULL,
  NumberOfGuests INT NOT NULL DEFAULT 0,
  NumberOfRooms INT NOT NULL,
  TotalPrice DECIMAL(10,2) NOT NULL,
  BookingStatus ENUM('Confirmed', 'Pending', 'Cancelled', 'Completed') NOT NULL DEFAULT 'Pending',
  SpecialRequests TEXT,
  GroupBookingDiscount DECIMAL(5,2) DEFAULT 0,
  PaymentStatus ENUM('Paid', 'Partial', 'Pending', 'Refunded') NOT NULL DEFAULT 'Pending',
  ConfirmationNumber VARCHAR(100) NOT NULL UNIQUE,
  BookedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (UserID) REFERENCES `USER`(UserID) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (HotelID) REFERENCES HOTEL(HotelID) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (RoomID) REFERENCES ROOM(RoomID) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_userID (UserID),
  INDEX idx_hotelID (HotelID),
  INDEX idx_roomID (RoomID),
  INDEX idx_bookingStatus (BookingStatus),
  INDEX idx_paymentStatus (PaymentStatus),
  INDEX idx_confirmationNumber (ConfirmationNumber),
  INDEX idx_bookedDate (BookedDate),
  INDEX idx_checkInDate (CheckInDate),
  INDEX idx_checkOutDate (CheckOutDate),
  INDEX idx_createdAt (CreatedAt),
  INDEX idx_user_hotel (UserID, HotelID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE 9: GUESTINFO
-- ============================================================
CREATE TABLE IF NOT EXISTS GUESTINFO (
  GuestInfoID INT AUTO_INCREMENT PRIMARY KEY,
  BookingID INT NOT NULL UNIQUE,
  FirstName VARCHAR(100) NOT NULL,
  LastName VARCHAR(100) NOT NULL,
  Email VARCHAR(255) NOT NULL,
  PhoneNumber VARCHAR(20) NOT NULL,
  StreetAddress VARCHAR(255),
  City VARCHAR(100),
  State VARCHAR(100),
  PostalCode VARCHAR(20),
  Country VARCHAR(100),
  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (BookingID) REFERENCES BOOKING(BookingID) ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX idx_bookingID (BookingID),
  INDEX idx_email (Email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE 10: REVIEW
-- ============================================================
CREATE TABLE IF NOT EXISTS REVIEW (
  ReviewID INT AUTO_INCREMENT PRIMARY KEY,
  HotelID INT NOT NULL,
  UserID INT NOT NULL,
  BookingID INT,
  Rating DECIMAL(2,1) NOT NULL,
  Title VARCHAR(255),
  ReviewText TEXT,
  IsVerifiedPurchase BOOLEAN NOT NULL DEFAULT FALSE,
  HelpfulCount INT DEFAULT 0,
  NumericRating INT NOT NULL,
  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (HotelID) REFERENCES HOTEL(HotelID) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (UserID) REFERENCES `USER`(UserID) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (BookingID) REFERENCES BOOKING(BookingID) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_hotelID (HotelID),
  INDEX idx_userID (UserID),
  INDEX idx_bookingID (BookingID),
  INDEX idx_rating (Rating),
  INDEX idx_numericRating (NumericRating),
  INDEX idx_isVerifiedPurchase (IsVerifiedPurchase),
  INDEX idx_createdAt (CreatedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE 11: PAYMENT
-- ============================================================
CREATE TABLE IF NOT EXISTS PAYMENT (
  PaymentID INT AUTO_INCREMENT PRIMARY KEY,
  BookingID INT NOT NULL,
  UserID INT NOT NULL,
  PaymentAmount DECIMAL(10,2) NOT NULL,
  PaymentMethod ENUM('CreditCard', 'DebitCard', 'NetBanking', 'Wallet', 'Cheque') NOT NULL,
  PaymentStatus ENUM('Success', 'Failed', 'Pending', 'Refunded') NOT NULL DEFAULT 'Pending',
  TransactionID VARCHAR(255) UNIQUE,
  PaymentDate DATETIME NOT NULL,
  RefundAmount DECIMAL(10,2) DEFAULT 0,
  RefundDate DATETIME,
  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (BookingID) REFERENCES BOOKING(BookingID) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (UserID) REFERENCES `USER`(UserID) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_bookingID (BookingID),
  INDEX idx_userID (UserID),
  INDEX idx_paymentStatus (PaymentStatus),
  INDEX idx_paymentMethod (PaymentMethod),
  INDEX idx_transactionID (TransactionID),
  INDEX idx_paymentDate (PaymentDate),
  INDEX idx_createdAt (CreatedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- SCHEMA CREATION COMPLETE
-- ============================================================
-- All tables have been created successfully in the 5033_ali database
-- Foreign key constraints and indexes have been configured for optimal performance


-- Wedding BnB Database - Sample Data (DML)
-- Database: 5033_ali
-- Created: November 26, 2025
-- Description: DML statements to populate MVP tables with sample data

USE 5033_ali;

-- ============================================================
-- INSERT DATA INTO USER TABLE
-- ============================================================
INSERT INTO `USER` (Email, Password, FirstName, LastName, PhoneNumber, Address, City, State, PostalCode, Country, Role, AccountStatus) VALUES
('bride@wedding.com', 'hashed_password_123', 'Sarah', 'Johnson', '2125551234', '123 Park Avenue', 'New York', 'NY', '10001', 'USA', 'Couple', 'Active'),
('groom@wedding.com', 'hashed_password_456', 'Michael', 'Johnson', '2125555678', '123 Park Avenue', 'New York', 'NY', '10001', 'USA', 'Couple', 'Active'),
('planner1@weddingbiz.com', 'hashed_password_789', 'Emily', 'Davis', '2125559999', '456 Madison Ave', 'New York', 'NY', '10022', 'USA', 'Planner', 'Active'),
('planner2@weddingbiz.com', 'hashed_password_101', 'James', 'Wilson', '2025558888', '789 5th Avenue', 'Washington', 'DC', '20001', 'USA', 'Planner', 'Active'),
('hotel_admin1@marriott.com', 'hashed_password_202', 'Robert', 'Smith', '2125557777', '301 Park Avenue', 'New York', 'NY', '10022', 'USA', 'HotelAdmin', 'Active'),
('hotel_admin2@hilton.com', 'hashed_password_303', 'Jennifer', 'Brown', '2025556666', '1250 24th St NW', 'Washington', 'DC', '20037', 'USA', 'HotelAdmin', 'Active'),
('admin@weddingbnb.com', 'hashed_password_404', 'David', 'Anderson', '2125554444', '100 Broadway', 'New York', 'NY', '10005', 'USA', 'SystemAdmin', 'Active'),
('john.doe@email.com', 'hashed_password_505', 'John', 'Doe', '2125553333', '321 5th Ave', 'New York', 'NY', '10016', 'USA', 'Couple', 'Active'),
('jane.smith@email.com', 'hashed_password_606', 'Jane', 'Smith', '2125552222', '654 Madison Ave', 'New York', 'NY', '10065', 'USA', 'Couple', 'Active'),
('mark.taylor@email.com', 'hashed_password_707', 'Mark', 'Taylor', '2025551111', '987 K Street', 'Washington', 'DC', '20005', 'USA', 'Couple', 'Active');

-- ============================================================
-- INSERT DATA INTO AMENITIES TABLE (Master Data)
-- ============================================================
INSERT INTO AMENITIES (AmenityName, AmenityCategory, Description) VALUES
('WiFi', 'Service', 'High-speed wireless internet'),
('Swimming Pool', 'Facility', 'Outdoor swimming pool with heated water'),
('Gym', 'Facility', 'Fully equipped fitness center'),
('Restaurant', 'Service', 'On-site dining restaurant'),
('Bar', 'Service', 'Full service bar and lounge'),
('Parking', 'Facility', 'Free parking available'),
('Spa', 'Facility', 'Full-service spa with massages'),
('Room Service', 'Service', '24-hour room service'),
('Air Conditioning', 'Comfort', 'Climate controlled rooms'),
('Concierge', 'Service', 'Concierge desk available'),
('Conference Rooms', 'Facility', 'Meeting and event spaces'),
('Elevator', 'Facility', 'Modern elevator service'),
('Pet Friendly', 'Service', 'Pets allowed in rooms'),
('Business Center', 'Facility', 'Internet and office services'),
('Movie Theater', 'Entertainment', 'In-house movie theater'),
('Kids Club', 'Entertainment', 'Children entertainment program'),
('Tennis Court', 'Facility', 'Tennis courts available'),
('Golf Course', 'Facility', 'On-site golf course'),
('Beach Access', 'Facility', 'Direct beach access'),
('Ballroom', 'Facility', 'Large ballroom for events');

-- ============================================================
-- INSERT DATA INTO HOTEL TABLE
-- ============================================================
INSERT INTO HOTEL (HotelName, StreetAddress, City, State, PostalCode, Country, PhoneNumber, Email, Website, Description, AverageRating, StarRating, TotalRooms, CheckInTime, CheckOutTime, ImageURL) VALUES
('The Plaza Hotel', '768 5th Avenue', 'New York', 'NY', '10019', 'USA', '2125593000', 'info@theplaza.com', 'www.theplaza.com', 'Iconic luxury hotel in Manhattan with elegant suites and world-class service', 4.8, 5, 282, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304'),
('The St. Regis New York', '2 E 55th St', 'New York', 'NY', '10022', 'USA', '2125531111', 'info@stregis.com', 'www.stregis.com', 'Ultra-luxury hotel with personalized butler service and gourmet dining', 4.9, 5, 256, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1566073771259-6a8506099945'),
('The Peninsula New York', '700 Fifth Avenue', 'New York', 'NY', '10019', 'USA', '2125314888', 'info@peninsula.com', 'www.peninsula.com', 'Luxury hotel with rooftop pool and fine dining establishments', 4.7, 5, 239, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1582719471384-894fbb16e074'),
('The Waldorf Astoria', '301 Park Avenue', 'New York', 'NY', '10022', 'USA', '2127332300', 'info@waldorf.com', 'www.waldorfnewyork.com', 'Historic luxury hotel with grand ballrooms and opulent suites', 4.6, 5, 375, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1561181286-d3fee7d55364'),
('The Carlyle', '35 E 76th St', 'New York', 'NY', '10021', 'USA', '2128447711', 'info@thecarlyle.com', 'www.rosewoodhotels.com', 'Upscale Manhattan hotel with Michelin-starred restaurant', 4.7, 5, 188, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1605735734335-552023b17385'),
('The Fairmont Washington DC', '2401 M Street NW', 'Washington', 'DC', '20037', 'USA', '2025294100', 'info@fairmont.com', 'www.fairmont.com', 'Elegant hotel in Georgetown with modern amenities and fine dining', 4.5, 5, 413, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1531142277223-25989ba26cae'),
('Park Hyatt Washington DC', '1201 24th St NW', 'Washington', 'DC', '20037', 'USA', '2025897000', 'info@parkhydc.com', 'www.washingtondc.park.hyatt.com', 'Contemporary luxury hotel with restaurant and spa', 4.6, 5, 213, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1518733759653-abc6e0849c5b'),
('The Ritz-Carlton New York', '50 Central Park South', 'New York', 'NY', '10019', 'USA', '2129081111', 'info@ritzny.com', 'www.ritzcarlton.com', 'Luxury hotel overlooking Central Park with gourmet dining', 4.8, 5, 257, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b'),
('Mandarin Oriental New York', '80 Columbus Circle', 'New York', 'NY', '10023', 'USA', '2125056900', 'info@mandarin.com', 'www.mandarinoriental.com', 'Asian-inspired luxury with spectacular city views', 4.7, 5, 248, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1578320585082-c92f7c3b1d60'),
('The Four Seasons Hotel New York', '57 E 57th St', 'New York', 'NY', '10022', 'USA', '2125589800', 'info@fourseasons.com', 'www.fourseasons.com', 'Ultra-luxury hotel with elegant suites and world-class dining', 4.9, 5, 368, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1595521624912-48416bd8575a');

-- ============================================================
-- INSERT DATA INTO HOTELAMENITIES TABLE
-- ============================================================
INSERT INTO HOTELAMENITIES (HotelID, AmenityID) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10), (1, 11),
(2, 1), (2, 3), (2, 4), (2, 5), (2, 6), (2, 7), (2, 8), (2, 10), (2, 11), (2, 20),
(3, 1), (3, 2), (3, 3), (3, 4), (3, 5), (3, 6), (3, 7), (3, 8), (3, 10),
(4, 1), (4, 3), (4, 4), (4, 5), (4, 6), (4, 7), (4, 8), (4, 10), (4, 11), (4, 20),
(5, 1), (5, 3), (5, 4), (5, 5), (5, 6), (5, 7), (5, 8), (5, 10),
(6, 1), (6, 2), (6, 3), (6, 4), (6, 6), (6, 7), (6, 8), (6, 10), (6, 11),
(7, 1), (7, 2), (7, 3), (7, 4), (7, 5), (7, 6), (7, 7), (7, 8), (7, 10),
(8, 1), (8, 2), (8, 3), (8, 4), (8, 5), (8, 6), (8, 7), (8, 8), (8, 10), (8, 20),
(9, 1), (9, 3), (9, 4), (9, 5), (9, 6), (9, 7), (9, 8), (9, 10),
(10, 1), (10, 2), (10, 3), (10, 4), (10, 5), (10, 6), (10, 7), (10, 8), (10, 10), (10, 11), (10, 20);

-- ============================================================
-- INSERT DATA INTO ROOM TABLE
-- ============================================================
INSERT INTO ROOM (HotelID, RoomNumber, RoomType, GuestCapacity, BedConfiguration, BasePrice, RoomStatus, Description) VALUES
(1, '1101', 'Single', 1, '1 Twin Bed', 350.00, 'Available', 'Cozy single room with city view'),
(1, '1102', 'Double', 2, '1 King Bed', 450.00, 'Available', 'Elegant double room with luxury linens'),
(1, '1103', 'Suite', 4, '1 King Bed + 2 Twin Beds', 750.00, 'Available', 'Spacious suite with living area'),
(1, '1104', 'Deluxe', 2, '1 King Bed', 600.00, 'Reserved', 'Deluxe room with premium amenities'),
(1, '1105', 'Presidential', 6, '2 King Beds + 2 Twin Beds', 1500.00, 'Available', 'Presidential suite with multiple rooms'),
(2, '2201', 'Single', 1, '1 Twin Bed', 400.00, 'Available', 'Modern single room'),
(2, '2202', 'Double', 2, '1 King Bed', 550.00, 'Available', 'Contemporary double room'),
(2, '2203', 'Suite', 4, '1 King Bed + 2 Twin Beds', 850.00, 'Available', 'Luxury suite with butler service'),
(2, '2204', 'Deluxe', 2, '1 King Bed', 700.00, 'Available', 'Premium deluxe room'),
(2, '2205', 'Presidential', 6, '2 King Beds + Sofa Bed', 2000.00, 'Available', 'Grand presidential suite'),
(3, '3301', 'Single', 1, '1 Twin Bed', 320.00, 'Available', 'Single room with rooftop access'),
(3, '3302', 'Double', 2, '1 King Bed', 420.00, 'Available', 'Double room with city views'),
(3, '3303', 'Suite', 4, '1 King Bed + 2 Twin Beds', 700.00, 'Available', 'Suite with pool access'),
(3, '3304', 'Deluxe', 2, '1 King Bed', 550.00, 'Occupied', 'Deluxe with rooftop pool'),
(3, '3305', 'Presidential', 6, '2 King Beds + 2 Twin Beds', 1400.00, 'Available', 'Presidential with terrace'),
(4, '4401', 'Single', 1, '1 Twin Bed', 380.00, 'Available', 'Historic single room'),
(4, '4402', 'Double', 2, '1 King Bed', 480.00, 'Available', 'Classic double room'),
(4, '4403', 'Suite', 4, '1 King Bed + 2 Twin Beds', 800.00, 'Available', 'Grand suite with ballroom access'),
(4, '4404', 'Deluxe', 2, '1 King Bed', 650.00, 'Available', 'Deluxe historic room'),
(4, '4405', 'Presidential', 6, '2 King Beds + 2 Twin Beds', 1800.00, 'Available', 'Grand presidential suite'),
(5, '5501', 'Single', 1, '1 Twin Bed', 300.00, 'Available', 'Intimate single room'),
(5, '5502', 'Double', 2, '1 King Bed', 400.00, 'Available', 'Cozy double room'),
(5, '5503', 'Suite', 4, '1 King Bed + 2 Twin Beds', 650.00, 'Available', 'Elegant suite'),
(5, '5504', 'Deluxe', 2, '1 King Bed', 500.00, 'Available', 'Deluxe room with restaurant access'),
(5, '5505', 'Presidential', 6, '2 King Beds + 2 Twin Beds', 1300.00, 'Available', 'Presidential with private bar'),
(6, '6601', 'Single', 1, '1 Twin Bed', 280.00, 'Available', 'Single room with city view'),
(6, '6602', 'Double', 2, '1 King Bed', 380.00, 'Available', 'Double room with modern design'),
(6, '6603', 'Suite', 4, '1 King Bed + 2 Twin Beds', 650.00, 'Available', 'Executive suite'),
(6, '6604', 'Deluxe', 2, '1 King Bed', 480.00, 'Available', 'Premium deluxe room'),
(6, '6605', 'Presidential', 6, '2 King Beds + Sofa', 1600.00, 'Available', 'Luxury presidential suite'),
(7, '7701', 'Single', 1, '1 Twin Bed', 290.00, 'Available', 'Contemporary single'),
(7, '7702', 'Double', 2, '1 King Bed', 390.00, 'Available', 'Modern double room'),
(7, '7703', 'Suite', 4, '1 King Bed + 2 Twin Beds', 680.00, 'Available', 'Contemporary suite'),
(7, '7704', 'Deluxe', 2, '1 King Bed', 500.00, 'Available', 'Deluxe contemporary'),
(7, '7705', 'Presidential', 6, '2 King Beds + Sofa Bed', 1700.00, 'Available', 'Modern presidential'),
(8, '8801', 'Single', 1, '1 Twin Bed', 360.00, 'Available', 'Luxury single room'),
(8, '8802', 'Double', 2, '1 King Bed', 460.00, 'Available', 'Luxury double room'),
(8, '8803', 'Suite', 4, '1 King Bed + 2 Twin Beds', 780.00, 'Available', 'Luxury suite with views'),
(8, '8804', 'Deluxe', 2, '1 King Bed', 620.00, 'Available', 'Premium luxury deluxe'),
(8, '8805', 'Presidential', 6, '2 King Beds + 2 Twin Beds', 1650.00, 'Available', 'Presidential with terrace'),
(9, '9901', 'Single', 1, '1 Twin Bed', 330.00, 'Available', 'Asian-inspired single'),
(9, '9902', 'Double', 2, '1 King Bed', 430.00, 'Available', 'Asian-inspired double'),
(9, '9903', 'Suite', 4, '1 King Bed + 2 Twin Beds', 720.00, 'Available', 'Luxury asian suite'),
(9, '9904', 'Deluxe', 2, '1 King Bed', 570.00, 'Available', 'Deluxe asian room'),
(9, '9905', 'Presidential', 6, '2 King Beds + 2 Twin Beds', 1550.00, 'Available', 'Presidential asian suite'),
(10, '10001', 'Single', 1, '1 Twin Bed', 370.00, 'Available', 'Ultra-luxury single'),
(10, '10002', 'Double', 2, '1 King Bed', 470.00, 'Available', 'Ultra-luxury double'),
(10, '10003', 'Suite', 4, '1 King Bed + 2 Twin Beds', 800.00, 'Available', 'Ultra-luxury suite'),
(10, '10004', 'Deluxe', 2, '1 King Bed', 640.00, 'Available', 'Ultra-luxury deluxe'),
(10, '10005', 'Presidential', 6, '2 King Beds + 2 Twin Beds', 2100.00, 'Available', 'Ultimate presidential suite');

-- ============================================================
-- INSERT DATA INTO ROOMAMENITIES TABLE
-- ============================================================
INSERT INTO ROOMAMENITIES (RoomID, AmenityID) VALUES
(1, 1), (1, 9),
(2, 1), (2, 9), (2, 8),
(3, 1), (3, 9), (3, 8), (3, 7),
(4, 1), (4, 9), (4, 8), (4, 7), (4, 3),
(5, 1), (5, 9), (5, 8), (5, 7), (5, 3), (5, 4),
(6, 1), (6, 9),
(7, 1), (7, 9), (7, 8),
(8, 1), (8, 9), (8, 8), (8, 7),
(9, 1), (9, 9), (9, 8), (9, 7), (9, 3),
(10, 1), (10, 9), (10, 8), (10, 7), (10, 3), (10, 4),
(11, 1), (11, 9),
(12, 1), (12, 9), (12, 8),
(13, 1), (13, 9), (13, 8), (13, 7), (13, 2),
(14, 1), (14, 9), (14, 8), (14, 7), (14, 2), (14, 3),
(15, 1), (15, 9), (15, 8), (15, 7), (15, 2), (15, 3), (15, 4),
(16, 1), (16, 9),
(17, 1), (17, 9), (17, 8),
(18, 1), (18, 9), (18, 8), (18, 7),
(19, 1), (19, 9), (19, 8), (19, 7), (19, 3),
(20, 1), (20, 9), (20, 8), (20, 7), (20, 3), (20, 4),
(21, 1), (21, 9),
(22, 1), (22, 9), (22, 8),
(23, 1), (23, 9), (23, 8), (23, 7),
(24, 1), (24, 9), (24, 8), (24, 7), (24, 3),
(25, 1), (25, 9), (25, 8), (25, 7), (25, 3), (25, 4),
(26, 1), (26, 9),
(27, 1), (27, 9), (27, 8),
(28, 1), (28, 9), (28, 8), (28, 7), (28, 2),
(29, 1), (29, 9), (29, 8), (29, 7), (29, 3),
(30, 1), (30, 9), (30, 8), (30, 7), (30, 3), (30, 4),
(31, 1), (31, 9),
(32, 1), (32, 9), (32, 8),
(33, 1), (33, 9), (33, 8), (33, 7),
(34, 1), (34, 9), (34, 8), (34, 7), (34, 3),
(35, 1), (35, 9), (35, 8), (35, 7), (35, 3), (35, 4),
(36, 1), (36, 9),
(37, 1), (37, 9), (37, 8),
(38, 1), (38, 9), (38, 8), (38, 7),
(39, 1), (39, 9), (39, 8), (39, 7), (39, 3),
(40, 1), (40, 9), (40, 8), (40, 7), (40, 3), (40, 4),
(41, 1), (41, 9),
(42, 1), (42, 9), (42, 8),
(43, 1), (43, 9), (43, 8), (43, 7),
(44, 1), (44, 9), (44, 8), (44, 7), (44, 3),
(45, 1), (45, 9), (45, 8), (45, 7), (45, 3), (45, 4),
(46, 1), (46, 9),
(47, 1), (47, 9), (47, 8),
(48, 1), (48, 9), (48, 8), (48, 7),
(49, 1), (49, 9), (49, 8), (49, 7), (49, 3),
(50, 1), (50, 9), (50, 8), (50, 7), (50, 3), (50, 4);

-- ============================================================
-- INSERT DATA INTO AVAILABILITY TABLE
-- ============================================================
INSERT INTO AVAILABILITY (RoomID, AvailableDate, AvailableRoomsCount, IsBooked, PriceOverride) VALUES
(1, '2025-12-15', 1, 0, NULL),
(1, '2025-12-16', 1, 0, NULL),
(1, '2025-12-17', 0, 1, NULL),
(1, '2025-12-18', 1, 0, 400.00),
(2, '2025-12-15', 1, 0, NULL),
(2, '2025-12-16', 1, 0, NULL),
(2, '2025-12-17', 1, 0, NULL),
(2, '2025-12-18', 1, 0, NULL),
(3, '2025-12-15', 1, 0, 850.00),
(3, '2025-12-16', 1, 0, NULL),
(3, '2025-12-17', 1, 0, NULL),
(3, '2025-12-18', 1, 0, NULL),
(4, '2025-12-15', 0, 1, NULL),
(4, '2025-12-16', 0, 1, NULL),
(4, '2025-12-17', 1, 0, NULL),
(4, '2025-12-18', 1, 0, NULL),
(5, '2025-12-15', 1, 0, 1500.00),
(5, '2025-12-16', 1, 0, NULL),
(5, '2025-12-17', 1, 0, NULL),
(5, '2025-12-18', 1, 0, NULL),
(6, '2025-12-15', 1, 0, NULL),
(6, '2025-12-16', 1, 0, NULL),
(6, '2025-12-17', 1, 0, NULL),
(6, '2025-12-18', 1, 0, NULL),
(7, '2025-12-15', 1, 0, NULL),
(7, '2025-12-16', 1, 0, NULL),
(7, '2025-12-17', 1, 0, NULL),
(7, '2025-12-18', 1, 0, NULL),
(8, '2025-12-15', 0, 1, NULL),
(8, '2025-12-16', 1, 0, NULL),
(9, '2025-12-15', 1, 0, NULL),
(9, '2025-12-16', 1, 0, NULL),
(10, '2025-12-15', 1, 0, 2000.00),
(10, '2025-12-16', 1, 0, NULL),
(11, '2025-12-15', 1, 0, NULL),
(11, '2025-12-16', 1, 0, NULL),
(12, '2025-12-15', 1, 0, NULL),
(12, '2025-12-16', 1, 0, NULL),
(13, '2025-12-15', 0, 1, NULL),
(13, '2025-12-16', 1, 0, NULL),
(14, '2025-12-15', 1, 0, NULL),
(14, '2025-12-16', 1, 0, NULL),
(15, '2025-12-15', 1, 0, 1400.00),
(15, '2025-12-16', 1, 0, NULL);

-- INSERT DATA INTO BOOKING TABLE
-- ============================================================
INSERT INTO BOOKING (UserID, HotelID, RoomID, CheckInDate, CheckOutDate, NumberOfGuests, NumberOfRooms, TotalPrice, BookingStatus, SpecialRequests, GroupBookingDiscount, PaymentStatus, ConfirmationNumber, BookedDate) VALUES
(1, 1, 2, '2025-12-15', '2025-12-18', 2, 1, 1350.00, 'Confirmed', 'Honeymoon suite upgrade if available', 0.00, 'Paid', 'WED-SAR-1001', '2025-11-10 09:30:00'),
(2, 1, 3, '2025-12-15', '2025-12-18', 4, 1, 2250.00, 'Confirmed', 'Flower arrangements for wedding', 0.00, 'Paid', 'WED-MIC-1002', '2025-11-10 09:45:00'),
(3, 1, 5, '2025-12-14', '2025-12-19', 6, 2, 4500.00, 'Confirmed', 'Ensure large ballroom availability', 10.00, 'Paid', 'WED-EMI-1003', '2025-11-08 13:15:00'),
(4, 2, 7, '2025-12-15', '2025-12-17', 2, 1, 840.00, 'Pending', 'Early check-in requested', 0.00, 'Pending', 'WED-JAM-1004', '2025-11-12 15:00:00'),
(5, 2, 9, '2025-12-16', '2025-12-18', 4, 1, 1700.00, 'Confirmed', 'Dietary requirements: Vegetarian', 0.00, 'Paid', 'WED-ROB-1005', '2025-11-13 10:10:00'),
(1, 3, 11, '2025-12-17', '2025-12-20', 1, 1, 960.00, 'Confirmed', 'City view preference', 0.00, 'Paid', 'WED-SAR-1006', '2025-11-15 08:55:00'),
(8, 3, 13, '2025-12-15', '2025-12-18', 4, 1, 1560.00, 'Cancelled', 'Cancelled due to schedule conflict', 0.00, 'Refunded', 'WED-JOH-1007', '2025-11-16 09:40:00'),
(9, 3, 15, '2025-12-16', '2025-12-19', 6, 2, 2800.00, 'Confirmed', 'Large group wedding event', 15.00, 'Paid', 'WED-JAN-1008', '2025-11-18 07:20:00'),
(10, 4, 17, '2025-12-15', '2025-12-17', 2, 1, 960.00, 'Pending', 'Spa package requested', 0.00, 'Pending', 'WED-MAR-1009', '2025-11-19 11:05:00'),
(3, 4, 20, '2025-12-18', '2025-12-21', 6, 1, 1800.00, 'Confirmed', 'Conference room for rehearsal', 5.00, 'Partial', 'WED-EMI-1010', '2025-11-20 16:50:00');

-- ============================================================
-- INSERT DATA INTO GUESTINFO TABLE
-- ============================================================
INSERT INTO GUESTINFO (BookingID, FirstName, LastName, Email, PhoneNumber, StreetAddress, City, State, PostalCode, Country) VALUES
(1, 'Sarah', 'Johnson', 'bride@wedding.com', '2125551234', '123 Park Avenue', 'New York', 'NY', '10001', 'USA'),
(2, 'Michael', 'Johnson', 'groom@wedding.com', '2125555678', '123 Park Avenue', 'New York', 'NY', '10001', 'USA'),
(3, 'Emily', 'Davis', 'planner1@weddingbiz.com', '2125559999', '456 Madison Ave', 'New York', 'NY', '10022', 'USA'),
(4, 'James', 'Wilson', 'planner2@weddingbiz.com', '2025558888', '789 5th Avenue', 'Washington', 'DC', '20001', 'USA'),
(5, 'Robert', 'Smith', 'hotel_admin1@marriott.com', '2125557777', '301 Park Avenue', 'New York', 'NY', '10022', 'USA'),
(6, 'Jennifer', 'Brown', 'hotel_admin2@hilton.com', '2025556666', '1250 24th St NW', 'Washington', 'DC', '20037', 'USA'),
(7, 'David', 'Anderson', 'admin@weddingbnb.com', '2125554444', '100 Broadway', 'New York', 'NY', '10005', 'USA'),
(8, 'John', 'Doe', 'john.doe@email.com', '2125553333', '321 5th Ave', 'New York', 'NY', '10016', 'USA'),
(9, 'Jane', 'Smith', 'jane.smith@email.com', '2125552222', '654 Madison Ave', 'New York', 'NY', '10065', 'USA'),
(10, 'Mark', 'Taylor', 'mark.taylor@email.com', '2025551111', '987 K Street', 'Washington', 'DC', '20005', 'USA');

-- ============================================================
-- INSERT DATA INTO REVIEW TABLE
-- ============================================================
INSERT INTO REVIEW (HotelID, UserID, BookingID, Rating, Title, ReviewText, IsVerifiedPurchase, HelpfulCount, NumericRating) VALUES
(1, 1, 1, 4.8, 'Exceptional Wedding Venue', 'The Plaza Hotel provided an exceptional experience for our wedding. The staff was attentive and the venue was perfect.', 1, 45, 5),
(1, 2, 2, 4.9, 'Outstanding Service', 'Outstanding service, beautiful rooms, and perfect location for our wedding celebration. Highly recommend!', 1, 52, 5),
(2, 3, 3, 4.7, 'Luxurious Experience', 'The St. Regis provided a luxurious experience with impeccable service and elegant suites.', 1, 38, 4),
(3, 4, 4, 4.6, 'Wonderful Rooftop Pool', 'Great hotel with a wonderful rooftop pool. The rooms were clean and the staff was helpful.', 0, 28, 4),
(4, 5, 5, 4.5, 'Historic Charm', 'The Waldorf Astoria has historic charm and great location. Perfect for a wedding event.', 1, 33, 5),
(5, 1, 6, 4.7, 'Elegant and Refined', 'Elegant and refined atmosphere. The restaurant was exceptional and the service impeccable.', 0, 41, 5),
(6, 8, 7, 4.6, 'Modern Luxury', 'Modern luxury in Georgetown. Great amenities and friendly staff. Would stay again.', 0, 35, 4),
(7, 9, 8, 4.8, 'Central Park Views', 'The Ritz-Carlton offers stunning Central Park views and world-class service. Perfect for weddings!', 1, 48, 5),
(8, 10, 9, 4.7, 'Excellent Spa Facilities', 'Excellent spa facilities and rooftop bar. The views of the city are magnificent.', 0, 37, 4),
(9, 3, 10, 4.9, 'Culinary Excellence', 'The Four Seasons excels in culinary excellence and guest service. A memorable experience.', 1, 55, 5),
(1, 9, NULL, 4.5, 'Good Location', 'Good location and elegant rooms. Staff could be more accommodating with special requests.', 0, 22, 4),
(2, 10, NULL, 4.8, 'Premium Experience', 'Premium experience at the St. Regis. The butler service was a nice touch.', 0, 44, 5),
(3, 1, NULL, 4.4, 'Decent Hotel', 'Decent hotel but prices are quite high. Rooms are nice though.', 0, 18, 4),
(4, 8, NULL, 4.7, 'Beautiful Historic Building', 'Beautiful historic building with great amenities. Breakfast is excellent.', 0, 39, 5),
(5, 9, NULL, 4.6, 'Upscale Dining', 'Upscale dining options and elegant rooms. A bit pricey but worth it.', 0, 31, 4);

-- ============================================================
-- INSERT DATA INTO PAYMENT TABLE
-- ============================================================
INSERT INTO PAYMENT (BookingID, UserID, PaymentAmount, PaymentMethod, PaymentStatus, TransactionID, PaymentDate, RefundAmount, RefundDate) VALUES
(1, 1, 1350.00, 'CreditCard', 'Success', 'TXN20251201001', '2025-12-01 10:30:00', 0.00, NULL),
(2, 2, 2250.00, 'CreditCard', 'Success', 'TXN20251201002', '2025-12-01 11:15:00', 0.00, NULL),
(3, 3, 4500.00, 'NetBanking', 'Success', 'TXN20251202001', '2025-12-02 09:45:00', 0.00, NULL),
(4, 4, 420.00, 'CreditCard', 'Pending', 'TXN20251202002', '2025-12-02 14:20:00', 0.00, NULL),
(5, 5, 1700.00, 'DebitCard', 'Success', 'TXN20251203001', '2025-12-03 10:00:00', 0.00, NULL),
(6, 1, 960.00, 'CreditCard', 'Success', 'TXN20251203002', '2025-12-03 15:30:00', 0.00, NULL),
(7, 8, 1560.00, 'CreditCard', 'Refunded', 'TXN20251204001', '2025-12-04 08:00:00', 1560.00, '2025-12-08 10:15:00'),
(8, 9, 2800.00, 'NetBanking', 'Success', 'TXN20251204002', '2025-12-04 12:45:00', 0.00, NULL),
(9, 10, 960.00, 'CreditCard', 'Pending', 'TXN20251205001', '2025-12-05 09:30:00', 0.00, NULL),
(10, 3, 1800.00, 'CreditCard', 'Success', 'TXN20251205002', '2025-12-05 16:00:00', 0.00, NULL),
(1, 1, 675.00, 'CreditCard', 'Success', 'TXN20251206001', '2025-12-06 11:00:00', 0.00, NULL),
(3, 3, 2250.00, 'NetBanking', 'Success', 'TXN20251206002', '2025-12-06 14:30:00', 0.00, NULL);

-- ============================================================
-- INSERT ADDITIONAL HOTELS - MAJOR USA CITIES
-- ============================================================

-- Los Angeles Hotels
INSERT INTO HOTEL (HotelName, StreetAddress, City, State, PostalCode, Country, PhoneNumber, Email, Website, Description, AverageRating, StarRating, TotalRooms, CheckInTime, CheckOutTime, ImageURL) VALUES
('The Beverly Hilton', '9876 Wilshire Blvd', 'Beverly Hills', 'CA', '90210', 'USA', '3102745000', 'info@beverlyhilton.com', 'www.beverlyhilton.com', 'Iconic luxury hotel in Beverly Hills with pool and fine dining', 4.6, 5, 290, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1566073771259-6a8506099945'),
('The Peninsula Beverly Hills', '9882 S Santa Monica Blvd', 'Beverly Hills', 'CA', '90212', 'USA', '3107516010', 'info@peninsula-bh.com', 'www.peninsula.com', 'Ultra-luxury hotel with rooftop pool and spa', 4.8, 5, 247, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1582719471384-894fbb16e074'),
('Hotel Bel-Air', '701 Stone Canyon Road', 'Los Angeles', 'CA', '90077', 'USA', '3103081151', 'info@hotelbelair.com', 'www.hotelbelair.com', 'Luxury hideaway with gardens and private cottages', 4.7, 5, 103, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304'),
('The Ritz-Carlton Los Angeles', '900 West Olympic Boulevard', 'Los Angeles', 'CA', '90015', 'USA', '2137411200', 'info@ritzcarlton-la.com', 'www.ritzcarlton.com', 'Downtown luxury with city views and rooftop bar', 4.7, 5, 206, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b'),
('Mondrian Los Angeles', '8440 Sunset Boulevard', 'West Hollywood', 'CA', '90069', 'USA', '3235506800', 'info@mondrian-la.com', 'www.mondrianhotel.com', 'Contemporary luxury with skybar and modern amenities', 4.5, 5, 237, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1578320585082-c92f7c3b1d60'),
('The Peninsula Chicago', '108 East Superior Street', 'Chicago', 'IL', '60611', 'USA', '3125373000', 'info@peninsula-chicago.com', 'www.peninsula.com', 'Luxury tower with spectacular views and fine dining', 4.8, 5, 339, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1595521624912-48416bd8575a'),
('The Ritz-Carlton Chicago', '160 East Pearson Street', 'Chicago', 'IL', '60611', 'USA', '3125738220', 'info@ritzcarlton-chicago.com', 'www.ritzcarlton.com', 'Luxury hotel with Lake Michigan views and spa', 4.7, 5, 434, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1566073771259-6a8506099945'),
('The Four Seasons Hotel Chicago', '120 East Delaware Place', 'Chicago', 'IL', '60611', 'USA', '3125800080', 'info@fourseasons-chicago.com', 'www.fourseasons.com', 'Ultra-luxury with private garden and world-class dining', 4.9, 5, 343, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1582719471384-894fbb16e074'),
('Mandarin Oriental Chicago', '540 North Michigan Avenue', 'Chicago', 'IL', '60611', 'USA', '3125881000', 'info@mandarin-chicago.com', 'www.mandarinoriental.com', 'Luxury with Asian-inspired design and city views', 4.6, 5, 316, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1578320585082-c92f7c3b1d60'),
('The Setai Miami Beach', '2001 Collins Avenue', 'Miami Beach', 'FL', '33139', 'USA', '3054413772', 'info@thesetai.com', 'www.thesetai.com', 'Ultra-luxury resort with private beach and restaurants', 4.8, 5, 123, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304'),
('Delano Miami Beach', '1685 Collins Avenue', 'Miami Beach', 'FL', '33139', 'USA', '3055381500', 'info@delano.com', 'www.delanohotels.com', 'Stylish beachfront with vibrant nightlife and dining', 4.7, 5, 194, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1582719471384-894fbb16e074'),
('The Ritz-Carlton Miami Beach', '1 Lincoln Road', 'Miami Beach', 'FL', '33139', 'USA', '3053398500', 'info@ritzcarlton-miami.com', 'www.ritzcarlton.com', 'Beachfront luxury with pool and oceanfront dining', 4.6, 5, 375, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1566073771259-6a8506099945'),
('Mandarin Oriental Miami', '500 Brickell Avenue', 'Miami', 'FL', '33131', 'USA', '3055139888', 'info@mandarin-miami.com', 'www.mandarinoriental.com', 'Luxury with Biscayne Bay views and spa', 4.7, 5, 312, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1578320585082-c92f7c3b1d60'),
('The Fairmont Heritage San Francisco', '950 Mason Street', 'San Francisco', 'CA', '94108', 'USA', '4158613900', 'info@fairmont-sf.com', 'www.fairmont.com', 'Historic luxury on Nob Hill with city views', 4.7, 5, 335, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304'),
('Mandarin Oriental San Francisco', '222 Sansome Street', 'San Francisco', 'CA', '94104', 'USA', '4155765800', 'info@mandarin-sf.com', 'www.mandarinoriental.com', 'Luxury with Bay and Golden Gate Bridge views', 4.8, 5, 158, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1578320585082-c92f7c3b1d60'),
('The St. Regis San Francisco', '125 Third Street', 'San Francisco', 'CA', '94103', 'USA', '4155363600', 'info@stregis-sf.com', 'www.stregis.com', 'Modern luxury with fine dining and spa', 4.7, 5, 260, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1566073771259-6a8506099945'),
('The Ritz-Carlton Boston', '15 Arlington Street', 'Boston', 'MA', '02116', 'USA', '6173357100', 'info@ritzcarlton-boston.com', 'www.ritzcarlton.com', 'Classic luxury overlooking Boston Public Garden', 4.7, 5, 273, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b'),
('The Mandarin Oriental Boston', '776 Boylston Street', 'Boston', 'MA', '02116', 'USA', '6179331000', 'info@mandarin-boston.com', 'www.mandarinoriental.com', 'Luxury in historic Back Bay with Asian-inspired design', 4.6, 5, 319, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1578320585082-c92f7c3b1d60'),
('The Four Seasons Hotel Boston', '200 Boylston Street', 'Boston', 'MA', '02116', 'USA', '6179636500', 'info@fourseasons-boston.com', 'www.fourseasons.com', 'Luxury with Back Bay views and fine dining', 4.8, 5, 345, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1595521624912-48416bd8575a'),
('Bellagio', '3600 Las Vegas Boulevard South', 'Las Vegas', 'NV', '89109', 'USA', '7023934000', 'info@bellagio.com', 'www.bellagio.com', 'Iconic luxury with fountain shows and fine dining', 4.6, 5, 3933, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304'),
('The Venetian', '3555 Las Vegas Boulevard South', 'Las Vegas', 'NV', '89109', 'USA', '7023144000', 'info@venetian.com', 'www.venetian.com', 'Luxury all-suite resort with gondola rides', 4.7, 5, 7117, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1582719471384-894fbb16e074'),
('Wynn Las Vegas', '3131 Las Vegas Boulevard South', 'Las Vegas', 'NV', '89109', 'USA', '7023707000', 'info@wynn.com', 'www.wynn.com', 'Ultra-luxury with golf course and fine restaurants', 4.8, 5, 4748, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1566073771259-6a8506099945'),
('Windsor Court Hotel', '300 Gravier Street', 'New Orleans', 'LA', '70130', 'USA', '5045235000', 'info@windsorcourthotel.com', 'www.windsorcourthotel.com', 'Elegant luxury hotel in Central Business District', 4.7, 5, 324, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1578320585082-c92f7c3b1d60'),
('Dauphine Orleans Hotel', '415 Dauphine Street', 'New Orleans', 'LA', '70112', 'USA', '5045864949', 'info@dauphineorleans.com', 'www.dauphineorleans.com', 'Boutique hotel in French Quarter with courtyard', 4.5, 4, 111, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b'),
('The Ritz-Carlton New Orleans', '921 Canal Street', 'New Orleans', 'LA', '70112', 'USA', '5045241331', 'info@ritzcarlton-nola.com', 'www.ritzcarlton.com', 'Luxury overlooking French Quarter and Mississippi River', 4.6, 5, 452, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1595521624912-48416bd8575a'),
('The Plaza Hotel Denver', '999 18th Street', 'Denver', 'CO', '80202', 'USA', '3036934000', 'info@plazadenver.com', 'www.plaza-hotel-denver.com', 'Luxury downtown with mountain views', 4.5, 5, 180, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1566073771259-6a8506099945'),
('The Brown Palace Hotel', '321 17th Street', 'Denver', 'CO', '80202', 'USA', '3039331311', 'info@brownpalace.com', 'www.brownpalace.com', 'Historic luxury with iconic architecture', 4.6, 5, 241, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1582719471384-894fbb16e074'),
('JW Marriott Denver', '1701 California Street', 'Denver', 'CO', '80202', 'USA', '3035722100', 'info@jwmarriott-denver.com', 'www.marriott.com', 'Modern luxury with rooftop restaurant', 4.7, 5, 297, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1578320585082-c92f7c3b1d60'),
('Fairmont Olympic Hotel', '411 University Street', 'Seattle', 'WA', '98104', 'USA', '2065217000', 'info@fairmont-seattle.com', 'www.fairmont.com', 'Historic luxury with rooftop pool and fine dining', 4.6, 5, 450, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304'),
('The Edgewater', '1112 Alaskan Way', 'Seattle', 'WA', '98101', 'USA', '2065287000', 'info@theedgewater.com', 'www.theedgewater.com', 'Waterfront luxury with Puget Sound views', 4.7, 5, 236, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1582719471384-894fbb16e074'),
('Pan Pacific Seattle', '2125 Terry Avenue North', 'Seattle', 'WA', '98121', 'USA', '2062649000', 'info@panpacific-seattle.com', 'www.panpacific.com', 'Modern luxury near Space Needle', 4.6, 5, 160, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1566073771259-6a8506099945'),
('Scottsdale Princess', '7575 East Princess Drive', 'Scottsdale', 'AZ', '85255', 'USA', '4807853900', 'info@princess.com', 'www.scottsdaleprincess.com', 'Luxury resort with golf and spa in desert', 4.7, 5, 452, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1578320585082-c92f7c3b1d60'),
('The Ritz-Carlton Scottsdale', '10350 North Ridgetop Road', 'Scottsdale', 'AZ', '85255', 'USA', '4802625010', 'info@ritzcarlton-scottsdale.com', 'www.ritzcarlton.com', 'Desert luxury with mountain views and spa', 4.8, 5, 253, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1595521624912-48416bd8575a'),
('The Royal Hawaiian', '2259 Kalakaua Avenue', 'Honolulu', 'HI', '96815', 'USA', '8089230022', 'info@royal-hawaii.com', 'www.royal-hawaiian.com', 'Iconic beachfront luxury on Oahu', 4.6, 5, 528, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304'),
('Halekulani', '2199 Kalia Road', 'Honolulu', 'HI', '96815', 'USA', '8089551912', 'info@halekulani.com', 'www.halekulani.com', 'Ultra-luxury beachfront with fine dining', 4.9, 5, 455, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1582719471384-894fbb16e074'),
('The Ritz-Carlton Kapalua', '1 Ritz Carlton Drive', 'Lahaina', 'HI', '96761', 'USA', '8088618000', 'info@ritzcarlton-kapalua.com', 'www.ritzcarlton.com', 'Luxury resort on Maui with ocean views', 4.7, 5, 548, '15:00:00', '11:00:00', 'https://images.unsplash.com/photo-1566073771259-6a8506099945');

-- ============================================================
-- INSERT ADDITIONAL HOTEL AMENITIES FOR NEW HOTELS
-- ============================================================
INSERT INTO HOTELAMENITIES (HotelID, AmenityID) VALUES
(11, 1), (11, 2), (11, 3), (11, 4), (11, 5), (11, 6), (11, 7), (11, 8), (11, 10),
(12, 1), (12, 2), (12, 3), (12, 4), (12, 5), (12, 6), (12, 7), (12, 8), (12, 10), (12, 20),
(13, 1), (13, 2), (13, 3), (13, 4), (13, 5), (13, 6), (13, 7), (13, 10),
(14, 1), (14, 2), (14, 3), (14, 4), (14, 5), (14, 6), (14, 7), (14, 8), (14, 10),
(15, 1), (15, 2), (15, 3), (15, 4), (15, 5), (15, 10),
(16, 1), (16, 3), (16, 4), (16, 5), (16, 6), (16, 7), (16, 8), (16, 10), (16, 11),
(17, 1), (17, 2), (17, 3), (17, 4), (17, 5), (17, 6), (17, 7), (17, 8), (17, 10),
(18, 1), (18, 2), (18, 3), (18, 4), (18, 5), (18, 6), (18, 7), (18, 8), (18, 10), (18, 20),
(19, 1), (19, 3), (19, 4), (19, 5), (19, 6), (19, 7), (19, 8), (19, 10),
(20, 1), (20, 2), (20, 3), (20, 4), (20, 5), (20, 6), (20, 7), (20, 8), (20, 15),
(21, 1), (21, 2), (21, 3), (21, 4), (21, 5), (21, 6), (21, 8), (21, 15), (21, 16),
(22, 1), (22, 2), (22, 3), (22, 4), (22, 5), (22, 6), (22, 8),
(23, 1), (23, 2), (23, 3), (23, 4), (23, 5), (23, 6), (23, 7), (23, 8),
(24, 1), (24, 3), (24, 4), (24, 5), (24, 6), (24, 7), (24, 8), (24, 10),
(25, 1), (25, 2), (25, 3), (25, 4), (25, 5), (25, 6), (25, 7), (25, 8),
(26, 1), (26, 3), (26, 4), (26, 5), (26, 6), (26, 7), (26, 8), (26, 10),
(27, 1), (27, 2), (27, 3), (27, 4), (27, 5), (27, 6), (27, 7), (27, 8), (27, 10),
(28, 1), (28, 3), (28, 4), (28, 5), (28, 6), (28, 7), (28, 8), (28, 10),
(29, 1), (29, 2), (29, 3), (29, 4), (29, 5), (29, 6), (29, 7), (29, 8), (29, 20),
(30, 1), (30, 2), (30, 3), (30, 4), (30, 5), (30, 6), (30, 8), (30, 15), (30, 16),
(31, 1), (31, 2), (31, 3), (31, 4), (31, 5), (31, 6), (31, 8), (31, 15), (31, 16),
(32, 1), (32, 2), (32, 3), (32, 4), (32, 5), (32, 6), (32, 8), (32, 15), (32, 17),
(33, 1), (33, 4), (33, 5), (33, 6), (33, 7), (33, 8), (33, 10),
(34, 1), (34, 4), (34, 5), (34, 8),
(35, 1), (35, 2), (35, 4), (35, 5), (35, 6), (35, 7), (35, 8), (35, 10),
(36, 1), (36, 3), (36, 4), (36, 5), (36, 6), (36, 8), (36, 10),
(37, 1), (37, 3), (37, 4), (37, 5), (37, 6), (37, 8),
(38, 1), (38, 3), (38, 4), (38, 5), (38, 6), (38, 8), (38, 10),
(39, 1), (39, 2), (39, 3), (39, 4), (39, 5), (39, 6), (39, 8), (39, 10),
(40, 1), (40, 2), (40, 3), (40, 4), (40, 5), (40, 8), (40, 10),
(41, 1), (41, 2), (41, 3), (41, 4), (41, 6), (41, 8),
(42, 1), (42, 2), (42, 3), (42, 4), (42, 5), (42, 6), (42, 7), (42, 8), (42, 17), (42, 18),
(43, 1), (43, 2), (43, 3), (43, 4), (43, 5), (43, 6), (43, 7), (43, 8), (43, 17),
(44, 1), (44, 2), (44, 3), (44, 4), (44, 5), (44, 6), (44, 8), (44, 15), (44, 19),
(45, 1), (45, 2), (45, 3), (45, 4), (45, 5), (45, 6), (45, 8), (45, 19),
(46, 1), (46, 2), (46, 3), (46, 4), (46, 5), (46, 6), (46, 7), (46, 8), (46, 19);

-- ============================================================
-- INSERT ADDITIONAL ROOMS FOR NEW HOTELS
-- ============================================================
INSERT INTO ROOM (HotelID, RoomNumber, RoomType, GuestCapacity, BedConfiguration, BasePrice, RoomStatus, Description) VALUES
(11, '11-101', 'Single', 1, '1 Twin Bed', 320.00, 'Available', 'Single room with city view'),
(11, '11-102', 'Double', 2, '1 King Bed', 420.00, 'Available', 'Double room with luxury linens'),
(11, '11-103', 'Suite', 4, '1 King Bed + 2 Twin Beds', 720.00, 'Available', 'Suite with living area'),
(11, '11-104', 'Deluxe', 2, '1 King Bed', 580.00, 'Available', 'Deluxe room with pool access'),
(12, '12-101', 'Single', 1, '1 Twin Bed', 380.00, 'Available', 'Modern single'),
(12, '12-102', 'Double', 2, '1 King Bed', 520.00, 'Available', 'Contemporary double'),
(12, '12-103', 'Suite', 4, '1 King Bed + 2 Twin Beds', 820.00, 'Available', 'Luxury suite'),
(12, '12-104', 'Presidential', 6, '2 King Beds + Sofa Bed', 1900.00, 'Available', 'Grand presidential'),
(13, '13-101', 'Single', 1, '1 Twin Bed', 350.00, 'Available', 'Cottage single'),
(13, '13-102', 'Double', 2, '1 King Bed', 450.00, 'Available', 'Cottage double'),
(13, '13-103', 'Suite', 4, '1 King Bed + 2 Twin Beds', 750.00, 'Available', 'Private cottage suite'),
(14, '14-101', 'Single', 1, '1 Twin Bed', 330.00, 'Available', 'Downtown single'),
(14, '14-102', 'Double', 2, '1 King Bed', 430.00, 'Available', 'Downtown double'),
(14, '14-103', 'Suite', 4, '1 King Bed + 2 Twin Beds', 730.00, 'Available', 'Downtown suite'),
(15, '15-101', 'Double', 2, '1 King Bed', 390.00, 'Available', 'Trendy double'),
(15, '15-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 690.00, 'Available', 'Modern suite'),
(16, '16-101', 'Single', 1, '1 Twin Bed', 310.00, 'Available', 'Tower single'),
(16, '16-102', 'Double', 2, '1 King Bed', 410.00, 'Available', 'Tower double'),
(16, '16-103', 'Suite', 4, '1 King Bed + 2 Twin Beds', 710.00, 'Available', 'Tower suite'),
(16, '16-104', 'Deluxe', 2, '1 King Bed', 560.00, 'Available', 'Deluxe with city view'),
(17, '17-101', 'Single', 1, '1 Twin Bed', 340.00, 'Available', 'Lake view single'),
(17, '17-102', 'Double', 2, '1 King Bed', 440.00, 'Available', 'Lake view double'),
(17, '17-103', 'Suite', 4, '1 King Bed + 2 Twin Beds', 740.00, 'Available', 'Lake view suite'),
(17, '17-104', 'Presidential', 6, '2 King Beds + 2 Twin Beds', 1700.00, 'Available', 'Presidential suite'),
(18, '18-101', 'Single', 1, '1 Twin Bed', 360.00, 'Available', 'Luxury single'),
(18, '18-102', 'Double', 2, '1 King Bed', 460.00, 'Available', 'Luxury double'),
(18, '18-103', 'Suite', 4, '1 King Bed + 2 Twin Beds', 760.00, 'Available', 'Luxury suite'),
(19, '19-101', 'Single', 1, '1 Twin Bed', 330.00, 'Available', 'Asian-inspired single'),
(19, '19-102', 'Double', 2, '1 King Bed', 430.00, 'Available', 'Asian-inspired double'),
(19, '19-103', 'Suite', 4, '1 King Bed + 2 Twin Beds', 730.00, 'Available', 'Asian suite'),
(20, '20-101', 'Single', 1, '1 Twin Bed', 300.00, 'Available', 'Beachfront single'),
(20, '20-102', 'Double', 2, '1 King Bed', 400.00, 'Available', 'Beachfront double'),
(20, '20-103', 'Suite', 4, '1 King Bed + 2 Twin Beds', 700.00, 'Available', 'Beachfront suite'),
(21, '21-101', 'Double', 2, '1 King Bed', 380.00, 'Available', 'Stylish double'),
(21, '21-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 680.00, 'Available', 'Stylish suite'),
(22, '22-101', 'Double', 2, '1 King Bed', 390.00, 'Available', 'Oceanfront double'),
(22, '22-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 690.00, 'Available', 'Oceanfront suite'),
(23, '23-101', 'Double', 2, '1 King Bed', 370.00, 'Available', 'Bay view double'),
(23, '23-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 670.00, 'Available', 'Bay view suite'),
(24, '24-101', 'Double', 2, '1 King Bed', 440.00, 'Available', 'Nob Hill double'),
(24, '24-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 740.00, 'Available', 'Nob Hill suite'),
(25, '25-101', 'Double', 2, '1 King Bed', 480.00, 'Available', 'Bay view double'),
(25, '25-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 780.00, 'Available', 'Bay view suite'),
(26, '26-101', 'Double', 2, '1 King Bed', 450.00, 'Available', 'SOMA double'),
(26, '26-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 750.00, 'Available', 'SOMA suite'),
(27, '27-101', 'Double', 2, '1 King Bed', 420.00, 'Available', 'Garden view double'),
(27, '27-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 720.00, 'Available', 'Garden view suite'),
(28, '28-101', 'Double', 2, '1 King Bed', 400.00, 'Available', 'Back Bay double'),
(28, '28-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 700.00, 'Available', 'Back Bay suite'),
(29, '29-101', 'Double', 2, '1 King Bed', 440.00, 'Available', 'Luxury double'),
(29, '29-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 740.00, 'Available', 'Luxury suite'),
(30, 'B-101', 'Double', 2, '1 King Bed', 280.00, 'Available', 'Resort double'),
(30, 'B-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 580.00, 'Available', 'Fountain view suite'),
(30, 'B-103', 'Deluxe', 2, '1 King Bed', 380.00, 'Available', 'Deluxe resort room'),
(31, 'V-101', 'Suite', 4, '2 King Beds + Sofa Bed', 650.00, 'Available', 'All-suite resort'),
(31, 'V-102', 'Deluxe', 2, '1 King Bed', 400.00, 'Available', 'Gondola suite'),
(32, 'W-101', 'Double', 2, '1 King Bed', 420.00, 'Available', 'Luxury double'),
(32, 'W-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 720.00, 'Available', 'Tower suite'),
(33, 'WC-101', 'Double', 2, '1 King Bed', 350.00, 'Available', 'Downtown double'),
(33, 'WC-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 650.00, 'Available', 'Downtown suite'),
(34, 'DO-101', 'Double', 2, '1 King Bed', 240.00, 'Available', 'French Quarter double'),
(35, 'RC-101', 'Double', 2, '1 King Bed', 360.00, 'Available', 'Canal Street double'),
(35, 'RC-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 660.00, 'Available', 'Canal Street suite'),
(36, 'PL-101', 'Double', 2, '1 King Bed', 300.00, 'Available', 'Downtown double'),
(36, 'PL-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 600.00, 'Available', 'Downtown suite'),
(37, 'BP-101', 'Double', 2, '1 King Bed', 320.00, 'Available', 'Historic double'),
(37, 'BP-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 620.00, 'Available', 'Historic suite'),
(38, 'JW-101', 'Double', 2, '1 King Bed', 340.00, 'Available', 'Modern double'),
(38, 'JW-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 640.00, 'Available', 'Modern suite'),
(39, 'FO-101', 'Double', 2, '1 King Bed', 380.00, 'Available', 'Olympic double'),
(39, 'FO-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 680.00, 'Available', 'Olympic suite'),
(40, 'EW-101', 'Double', 2, '1 King Bed', 420.00, 'Available', 'Waterfront double'),
(40, 'EW-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 720.00, 'Available', 'Waterfront suite'),
(41, 'PP-101', 'Double', 2, '1 King Bed', 340.00, 'Available', 'Space Needle view'),
(41, 'PP-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 640.00, 'Available', 'Space Needle suite'),
(42, 'SP-101', 'Double', 2, '1 King Bed', 360.00, 'Available', 'Resort double'),
(42, 'SP-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 660.00, 'Available', 'Golf resort suite'),
(43, 'RS-101', 'Double', 2, '1 King Bed', 400.00, 'Available', 'Desert double'),
(43, 'RS-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 700.00, 'Available', 'Desert suite'),
(44, 'RH-101', 'Double', 2, '1 King Bed', 520.00, 'Available', 'Beachfront double'),
(44, 'RH-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 820.00, 'Available', 'Beachfront suite'),
(45, 'HK-101', 'Double', 2, '1 King Bed', 580.00, 'Available', 'Luxury beachfront'),
(45, 'HK-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 880.00, 'Available', 'Luxury suite'),
(46, 'RK-101', 'Double', 2, '1 King Bed', 500.00, 'Available', 'Maui beachfront'),
(46, 'RK-102', 'Suite', 4, '1 King Bed + 2 Twin Beds', 800.00, 'Available', 'Maui suite');

-- ============================================================
-- INSERT ADDITIONAL AVAILABILITY DATA FOR NEW HOTELS
-- ============================================================
INSERT INTO AVAILABILITY (RoomID, AvailableDate, AvailableRoomsCount, IsBooked, PriceOverride) VALUES
(51, '2025-12-15', 1, 0, NULL), (51, '2025-12-16', 1, 0, NULL), (51, '2025-12-17', 1, 0, NULL), (51, '2025-12-18', 1, 0, NULL),
(52, '2025-12-15', 1, 0, NULL), (52, '2025-12-16', 1, 0, NULL), (52, '2025-12-17', 1, 0, NULL), (52, '2025-12-18', 1, 0, NULL),
(53, '2025-12-15', 0, 1, NULL), (53, '2025-12-16', 1, 0, 800.00), (53, '2025-12-17', 1, 0, NULL), (53, '2025-12-18', 1, 0, NULL),
(54, '2025-12-15', 1, 0, NULL), (54, '2025-12-16', 1, 0, NULL), (54, '2025-12-17', 1, 0, NULL), (54, '2025-12-18', 1, 0, NULL),
(55, '2025-12-15', 1, 0, NULL), (55, '2025-12-16', 1, 0, NULL), (55, '2025-12-17', 1, 0, NULL), (55, '2025-12-18', 1, 0, NULL),
(56, '2025-12-15', 1, 0, NULL), (56, '2025-12-16', 1, 0, NULL), (56, '2025-12-17', 1, 0, NULL), (56, '2025-12-18', 1, 0, NULL),
(57, '2025-12-15', 1, 0, NULL), (57, '2025-12-16', 1, 0, NULL), (57, '2025-12-17', 0, 1, NULL), (57, '2025-12-18', 1, 0, NULL),
(58, '2025-12-15', 1, 0, 1800.00), (58, '2025-12-16', 1, 0, NULL), (58, '2025-12-17', 1, 0, NULL), (58, '2025-12-18', 1, 0, NULL),
(59, '2025-12-15', 1, 0, NULL), (59, '2025-12-16', 1, 0, NULL), (59, '2025-12-17', 1, 0, NULL), (59, '2025-12-18', 1, 0, NULL),
(60, '2025-12-15', 1, 0, NULL), (60, '2025-12-16', 1, 0, NULL), (60, '2025-12-17', 1, 0, NULL), (60, '2025-12-18', 1, 0, NULL),
(61, '2025-12-15', 0, 1, NULL), (61, '2025-12-16', 1, 0, 800.00), (61, '2025-12-17', 1, 0, NULL), (61, '2025-12-18', 1, 0, NULL),
(62, '2025-12-15', 1, 0, NULL), (62, '2025-12-16', 1, 0, NULL), (62, '2025-12-17', 1, 0, NULL), (62, '2025-12-18', 1, 0, NULL),
(63, '2025-12-15', 1, 0, NULL), (63, '2025-12-16', 1, 0, NULL), (63, '2025-12-17', 1, 0, NULL), (63, '2025-12-18', 1, 0, NULL),
(64, '2025-12-15', 1, 0, NULL), (64, '2025-12-16', 1, 0, NULL), (64, '2025-12-17', 1, 0, NULL), (64, '2025-12-18', 1, 0, NULL),
(65, '2025-12-15', 1, 0, NULL), (65, '2025-12-16', 1, 0, NULL), (65, '2025-12-17', 0, 1, NULL), (65, '2025-12-18', 1, 0, NULL),
(66, '2025-12-15', 1, 0, 1600.00), (66, '2025-12-16', 1, 0, NULL), (66, '2025-12-17', 1, 0, NULL), (66, '2025-12-18', 1, 0, NULL),
(67, '2025-12-15', 1, 0, NULL), (67, '2025-12-16', 1, 0, NULL), (67, '2025-12-17', 1, 0, NULL), (67, '2025-12-18', 1, 0, NULL),
(68, '2025-12-15', 1, 0, NULL), (68, '2025-12-16', 1, 0, NULL), (68, '2025-12-17', 1, 0, NULL), (68, '2025-12-18', 1, 0, NULL),
(69, '2025-12-15', 0, 1, 800.00), (69, '2025-12-16', 1, 0, NULL), (69, '2025-12-17', 1, 0, NULL), (69, '2025-12-18', 1, 0, NULL),
(70, '2025-12-15', 1, 0, NULL), (70, '2025-12-16', 1, 0, NULL), (70, '2025-12-17', 1, 0, NULL), (70, '2025-12-18', 1, 0, NULL),
(71, '2025-12-15', 1, 0, NULL), (71, '2025-12-16', 1, 0, NULL), (71, '2025-12-17', 1, 0, NULL), (71, '2025-12-18', 1, 0, NULL),
(72, '2025-12-15', 1, 0, NULL), (72, '2025-12-16', 1, 0, NULL), (72, '2025-12-17', 1, 0, NULL), (72, '2025-12-18', 1, 0, NULL),
(73, '2025-12-15', 1, 0, NULL), (73, '2025-12-16', 1, 0, NULL), (73, '2025-12-17', 1, 0, NULL), (73, '2025-12-18', 1, 0, NULL),
(74, '2025-12-15', 1, 0, NULL), (74, '2025-12-16', 1, 0, NULL), (74, '2025-12-17', 1, 0, NULL), (74, '2025-12-18', 1, 0, NULL),
(75, '2025-12-15', 1, 0, NULL), (75, '2025-12-16', 1, 0, NULL), (75, '2025-12-17', 1, 0, NULL), (75, '2025-12-18', 1, 0, NULL),
(76, '2025-12-15', 1, 0, NULL), (76, '2025-12-16', 1, 0, NULL), (76, '2025-12-17', 1, 0, NULL), (76, '2025-12-18', 1, 0, NULL),
(77, '2025-12-15', 1, 0, NULL), (77, '2025-12-16', 1, 0, NULL), (77, '2025-12-17', 1, 0, NULL), (77, '2025-12-18', 1, 0, NULL),
(78, '2025-12-15', 1, 0, NULL), (78, '2025-12-16', 1, 0, NULL), (78, '2025-12-17', 1, 0, NULL), (78, '2025-12-18', 1, 0, NULL),
(79, '2025-12-15', 1, 0, NULL), (79, '2025-12-16', 1, 0, NULL), (79, '2025-12-17', 1, 0, NULL), (79, '2025-12-18', 1, 0, NULL),
(80, '2025-12-15', 1, 0, NULL), (80, '2025-12-16', 1, 0, NULL), (80, '2025-12-17', 1, 0, NULL), (80, '2025-12-18', 1, 0, NULL),
(81, '2025-12-15', 1, 0, NULL), (81, '2025-12-16', 1, 0, NULL), (81, '2025-12-17', 1, 0, NULL), (81, '2025-12-18', 1, 0, NULL),
(82, '2025-12-15', 1, 0, NULL), (82, '2025-12-16', 1, 0, NULL), (82, '2025-12-17', 1, 0, NULL), (82, '2025-12-18', 1, 0, NULL),
(83, '2025-12-15', 1, 0, NULL), (83, '2025-12-16', 1, 0, NULL), (83, '2025-12-17', 1, 0, NULL), (83, '2025-12-18', 1, 0, NULL),
(84, '2025-12-15', 1, 0, NULL), (84, '2025-12-16', 1, 0, NULL), (84, '2025-12-17', 1, 0, NULL), (84, '2025-12-18', 1, 0, NULL),
(85, '2025-12-15', 1, 0, NULL), (85, '2025-12-16', 1, 0, NULL), (85, '2025-12-17', 1, 0, NULL), (85, '2025-12-18', 1, 0, NULL),
(86, '2025-12-15', 1, 0, NULL), (86, '2025-12-16', 1, 0, NULL), (86, '2025-12-17', 1, 0, NULL), (86, '2025-12-18', 1, 0, NULL),
(87, '2025-12-15', 1, 0, NULL), (87, '2025-12-16', 1, 0, NULL), (87, '2025-12-17', 1, 0, NULL), (87, '2025-12-18', 1, 0, NULL),
(88, '2025-12-15', 1, 0, NULL), (88, '2025-12-16', 1, 0, NULL), (88, '2025-12-17', 1, 0, NULL), (88, '2025-12-18', 1, 0, NULL),
(89, '2025-12-15', 1, 0, NULL), (89, '2025-12-16', 1, 0, NULL), (89, '2025-12-17', 1, 0, NULL), (89, '2025-12-18', 1, 0, NULL),
(90, '2025-12-15', 1, 0, NULL), (90, '2025-12-16', 1, 0, NULL), (90, '2025-12-17', 1, 0, NULL), (90, '2025-12-18', 1, 0, NULL),
(91, '2025-12-15', 1, 0, NULL), (91, '2025-12-16', 1, 0, NULL), (91, '2025-12-17', 1, 0, NULL), (91, '2025-12-18', 1, 0, NULL),
(92, '2025-12-15', 1, 0, NULL), (92, '2025-12-16', 1, 0, NULL), (92, '2025-12-17', 1, 0, NULL), (92, '2025-12-18', 1, 0, NULL),
(93, '2025-12-15', 1, 0, NULL), (93, '2025-12-16', 1, 0, NULL), (93, '2025-12-17', 1, 0, NULL), (93, '2025-12-18', 1, 0, NULL),
(94, '2025-12-15', 1, 0, NULL), (94, '2025-12-16', 1, 0, NULL), (94, '2025-12-17', 1, 0, NULL), (94, '2025-12-18', 1, 0, NULL),
(95, '2025-12-15', 1, 0, NULL), (95, '2025-12-16', 1, 0, NULL), (95, '2025-12-17', 1, 0, NULL), (95, '2025-12-18', 1, 0, NULL),
(96, '2025-12-15', 1, 0, NULL), (96, '2025-12-16', 1, 0, NULL), (96, '2025-12-17', 1, 0, NULL), (96, '2025-12-18', 1, 0, NULL),
(97, '2025-12-15', 1, 0, NULL), (97, '2025-12-16', 1, 0, NULL), (97, '2025-12-17', 1, 0, NULL), (97, '2025-12-18', 1, 0, NULL),
(98, '2025-12-15', 1, 0, NULL), (98, '2025-12-16', 1, 0, NULL), (98, '2025-12-17', 1, 0, NULL), (98, '2025-12-18', 1, 0, NULL),
(99, '2025-12-15', 1, 0, NULL), (99, '2025-12-16', 1, 0, NULL), (99, '2025-12-17', 1, 0, NULL), (99, '2025-12-18', 1, 0, NULL),
(100, '2025-12-15', 1, 0, NULL), (100, '2025-12-16', 1, 0, NULL), (100, '2025-12-17', 1, 0, NULL), (100, '2025-12-18', 1, 0, NULL);

-- ============================================================
-- DML STATEMENTS COMPLETE
-- ============================================================
-- Merged data successfully inserted
-- Total Hotels: 10 (original) + 36 (new) = 46 hotels across major USA cities
-- Total Rooms: 50 (original) + 86 (new) = 136 rooms
-- All user bookings, reviews, and payment data included
-- Users can now search and find multiple hotel options in various cities

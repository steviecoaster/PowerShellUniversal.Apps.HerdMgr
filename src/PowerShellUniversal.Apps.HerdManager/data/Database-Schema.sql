-- Gundy Ridge Herd Manager Database Schema
-- SQLite Database for Cattle Weight Management and Rate of Gain Tracking

-- Table: Cattle
-- Stores individual animal information
CREATE TABLE IF NOT EXISTS Cattle (
    CattleID INTEGER PRIMARY KEY AUTOINCREMENT,
    TagNumber VARCHAR(50) UNIQUE NOT NULL,
    OriginFarm VARCHAR(100) NOT NULL,
    Name VARCHAR(100),
    Breed VARCHAR(50),
    Gender VARCHAR(10) CHECK(Gender IN ('Steer', 'Heifer')),
    BirthDate DATE,
    PurchaseDate DATE,
    Location VARCHAR(50) CHECK(Location IN ('Pen 1', 'Pen 2', 'Pen 3', 'Pen 4', 'Pen 5', 'Pen 6', 'Quarantine', 'Pasture')),
    Status VARCHAR(20) DEFAULT 'Active' CHECK(Status IN ('Active', 'Sold', 'Deceased', 'Transferred')),
    Notes TEXT,
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Table: WeightRecords
-- Stores all weight measurements over time
CREATE TABLE IF NOT EXISTS WeightRecords (
    WeightRecordID INTEGER PRIMARY KEY AUTOINCREMENT,
    CattleID INTEGER NOT NULL,
    WeightDate DATE NOT NULL,
    Weight DECIMAL(10,2) NOT NULL,
    WeightUnit VARCHAR(10) DEFAULT 'lbs' CHECK(WeightUnit IN ('lbs', 'kg')),
    MeasurementMethod VARCHAR(50), -- e.g., 'Scale', 'Visual Estimate', 'Tape Measure'
    Notes TEXT,
    RecordedBy VARCHAR(100),
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CattleID) REFERENCES Cattle(CattleID) ON DELETE CASCADE
);

-- Table: RateOfGainCalculations
-- Stores calculated rate of gain metrics between date ranges
CREATE TABLE IF NOT EXISTS RateOfGainCalculations (
    CalculationID INTEGER PRIMARY KEY AUTOINCREMENT,
    CattleID INTEGER NOT NULL,
    StartWeightRecordID INTEGER NOT NULL,
    EndWeightRecordID INTEGER NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    StartWeight DECIMAL(10,2) NOT NULL,
    EndWeight DECIMAL(10,2) NOT NULL,
    TotalWeightGain DECIMAL(10,2) NOT NULL,
    DaysBetween INTEGER NOT NULL,
    AverageDailyGain DECIMAL(10,4) NOT NULL, -- ADG in lbs/day
    CalculatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CattleID) REFERENCES Cattle(CattleID) ON DELETE CASCADE,
    FOREIGN KEY (StartWeightRecordID) REFERENCES WeightRecords(WeightRecordID),
    FOREIGN KEY (EndWeightRecordID) REFERENCES WeightRecords(WeightRecordID)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_cattle_tag ON Cattle(TagNumber);
CREATE INDEX IF NOT EXISTS idx_cattle_status ON Cattle(Status);
CREATE INDEX IF NOT EXISTS idx_weight_cattle_date ON WeightRecords(CattleID, WeightDate);
CREATE INDEX IF NOT EXISTS idx_rog_cattle ON RateOfGainCalculations(CattleID);

-- View: CattleWithLatestWeight
-- Convenient view to see each animal with their most recent weight
CREATE VIEW IF NOT EXISTS CattleWithLatestWeight AS
SELECT 
    c.CattleID,
    c.TagNumber,
    c.OriginFarm,
    c.Name,
    c.Breed,
    c.Gender,
    c.BirthDate,
    c.Location,
    c.Status,
    w.WeightDate AS LatestWeightDate,
    w.Weight AS LatestWeight,
    w.WeightUnit
FROM Cattle c
LEFT JOIN (
    SELECT CattleID, WeightDate, Weight, WeightUnit,
           ROW_NUMBER() OVER (PARTITION BY CattleID ORDER BY WeightDate DESC) as rn
    FROM WeightRecords
) w ON c.CattleID = w.CattleID AND w.rn = 1;

-- View: RecentRateOfGain
-- Shows recent rate of gain calculations
CREATE VIEW IF NOT EXISTS RecentRateOfGain AS
SELECT 
    c.TagNumber,
    c.Name,
    rog.StartDate,
    rog.EndDate,
    rog.StartWeight,
    rog.EndWeight,
    rog.TotalWeightGain,
    rog.DaysBetween,
    rog.AverageDailyGain,
    ROUND(rog.AverageDailyGain * 30, 2) AS MonthlyGain,
    rog.CalculatedDate
FROM RateOfGainCalculations rog
JOIN Cattle c ON rog.CattleID = c.CattleID
ORDER BY rog.CalculatedDate DESC;

-- Table: HealthRecords
-- Stores health-related events including vaccinations, treatments, and observations
CREATE TABLE IF NOT EXISTS HealthRecords (
    HealthRecordID INTEGER PRIMARY KEY AUTOINCREMENT,
    CattleID INTEGER NOT NULL,
    RecordDate DATE NOT NULL,
    RecordType VARCHAR(50) NOT NULL CHECK(RecordType IN ('Vaccination', 'Treatment', 'Observation', 'Veterinary Visit', 'Other')),
    Title VARCHAR(200) NOT NULL,
    Description TEXT,
    VeterinarianName VARCHAR(100),
    Medication VARCHAR(200),
    Dosage VARCHAR(100),
    Cost DECIMAL(10,2),
    NextDueDate DATE, -- For vaccinations or follow-up treatments
    Notes TEXT,
    RecordedBy VARCHAR(100),
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CattleID) REFERENCES Cattle(CattleID) ON DELETE CASCADE
);

-- Index for health records
CREATE INDEX IF NOT EXISTS idx_health_cattle_date ON HealthRecords(CattleID, RecordDate);
CREATE INDEX IF NOT EXISTS idx_health_type ON HealthRecords(RecordType);
CREATE INDEX IF NOT EXISTS idx_health_next_due ON HealthRecords(NextDueDate);

-- Table: FeedRecords
-- Stores daily feeding records for the herd
CREATE TABLE IF NOT EXISTS FeedRecords (
    FeedRecordID INTEGER PRIMARY KEY AUTOINCREMENT,
    FeedDate DATE NOT NULL,
    HaylagePounds DECIMAL(10,2) DEFAULT 0,
    SilagePounds DECIMAL(10,2) DEFAULT 0,
    HighMoistureCornPounds DECIMAL(10,2) DEFAULT 0,
    TotalPounds DECIMAL(10,2) NOT NULL,
    Notes TEXT,
    RecordedBy VARCHAR(100),
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(FeedDate) -- Only one feed record per day
);

-- Index for feed records
CREATE INDEX IF NOT EXISTS idx_feed_date ON FeedRecords(FeedDate);


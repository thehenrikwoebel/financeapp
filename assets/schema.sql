CREATE TABLE CostTypes (
        ID INTEGER PRIMARY KEY,
        Name TEXT NOT NULL,
        CreatedAt INTEGER,
        UpdatedAt INTEGER
    , icon TEXT);
CREATE TABLE Expenses (
        ID INTEGER PRIMARY KEY,
        Name TEXT NOT NULL,
        Amount REAL,
        CreatedAt INTEGER,
        UpdatedAt INTEGER,
        CostTypeID INTEGER,
        FOREIGN KEY (CostTypeID) REFERENCES CostTypes(ID) ON DELETE SET NULL
    );
INSERT INTO CostTypes (ID, Name, icon) VALUES (0, 'no category', 'question_mark');

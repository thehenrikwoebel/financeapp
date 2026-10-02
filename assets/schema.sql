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
CREATE TABLE IF NOT EXISTS ConfiguredExpenses (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  ExpenseName TEXT NOT NULL UNIQUE,
  NewExpenseName TEXT NOT NULL,
  CostTypeID INTEGER NOT NULL,
  FOREIGN KEY (CostTypeID) REFERENCES CostTypes(ID)
);
INSERT INTO CostTypes (ID, Name, icon) VALUES (0, 'no category', 'question_mark');

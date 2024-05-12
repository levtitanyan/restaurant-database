USE Restaurant;

-- increase by 20% the Salaries of workers who have default salary <25
DELIMITER //

CREATE TRIGGER UpdateSalaryBeforeInsert
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.Salary < 25000 THEN
        SET NEW.Salary = NEW.Salary * 1.2; 
    END IF;
END //

DELIMITER ;


INSERT INTO Employee (EmployeeID, FirstName, LastName, Phone, Email, JobPosition, Salary, ReportsTo)
VALUES
(100, 'Kwame', 'Agyeman', '086-567-234', 'kwame.agyeman@1may.com', 'Dishwasher', 24000.00, 2),
(101, 'Chinonso', 'Okafor', '086-123-789', 'chinonso.okafor@1may.com', 'Dishwasher', 28000.00, 2),
(102, 'Ayanda', 'Zulu', '086-234-456', 'ayanda.zulu@1may.com', 'Dishwasher', 20000.00, 2),
(103, 'Fatoumata', 'Sow', '086-345-123', 'fatoumata.sow@1may.com', 'Dishwasher', 20000.00, 2),
(104, 'Musa', 'Diallo', '086-416-789', 'musa.diallo@1may.com', 'Dishwasher', 10000.00, 2),
(105, 'Sekou', 'Koulibaly', '086-507-234', 'sekou.koulibaly@1may.com', 'Dishwasher', 24000.00, 2),
(106, 'Ngozi', 'Okonkwo', '086-120-789', 'ngozi.okonkwo@1may.com', 'Dishwasher', 23000.00, 2),
(107, 'Abeba', 'Alemu', '086-204-456', 'abeba.alemu@1may.com', 'Dishwasher', 22000.00, 2);

SELECT * FROM Employee ORDER BY employeeid DESC;


-- Default value 3 for  capacity of new Patio tables

DELIMITER //

CREATE TRIGGER SetDefaultCapacityForPatio
BEFORE INSERT ON TheTable
FOR EACH ROW
BEGIN
    IF NEW.Location = 'Patio' THEN
        SET NEW.Capacity = 3;
    END IF;
END //

DELIMITER ;


INSERT INTO TheTable (TableNumber, Capacity, TableStatus, Location)
VALUES
    (31, 2, 'Available', 'Main Dining Area'),  
    (32, 6, 'Available', 'Patio'),          
    (33, 3, 'Available', 'Patio'),          
    (34, 5, 'Available', 'Bar Area'),          
    (35, 4, 'Available', 'Patio'), 
    (36, 2, 'Available', 'Patio'),            
    (37, 4, 'Available', 'Patio'),         
    (38, 8, 'Available', 'Main Dining Area'), 
    (39, 5, 'Available', 'Patio'),         
    (40, 3, 'Available', 'Private Room'); 



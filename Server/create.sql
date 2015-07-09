USE chatdb;
CREATE TABLE ChatRooms( id int NOT NULL AUTO_INCREMENT PRIMARY KEY,roomname varchar(255) NOT NULL );
INSERT INTO ChatRooms (roomname) VALUES ('friends');
CREATE TABLE friends ( id int NOT NULL AUTO_INCREMENT PRIMARY KEY, sharename varchar(255) NOT NULL, secret varchar(255) NOT NULL,username varchar(255) NOT NULL);
INSERT INTO friends (sharename, secret, username) VALUES ('study', 'maria', 'Juseman');
INSERT INTO friends (sharename, secret, username) VALUES ('study', 'maria', 'Auseman');
INSERT INTO friends (sharename, secret, username) VALUES ('study', 'maria', 'Buseman');
INSERT INTO friends (sharename, secret, username) VALUES ('study', 'maria', 'Cuseman');
<?php
    class RedeemAPI {

        private $db;

        function __construct() {
            $this->db = new mysqli('localhost', 'root', 'jshjso1116', 'chatdb');
            $this->db->autocommit(FALSE);
			$this->createChatRooms();
        }

        function __destruct() {
            $this->db->close();
        }

		function createChatRooms() {
			$rs = $this->db->query("SHOW TABLES LIKE 'ChatRooms'");
            if($rs->num_rows != 1){
                $this->db->query('CREATE TABLE ChatRooms( id int NOT NULL AUTO_INCREMENT PRIMARY KEY,roomname varchar(255) NOT NULL )');
				$this->db->commit();
            }
        }

		function isExistChatRoom($chatroom) {
            $rs = $this->db->query("SELECT roomname FROM ChatRooms WHERE roomname = '$chatroom'");
            if($rs->num_rows > 0) {
                return true;
            }
            else{
                return false;
            }
        }

		function createChatRoom($chatroom){
			if( $this->isExistChatRoom($chatroom) === false ){
                $this->db->query("INSERT INTO ChatRooms (roomname) VALUES ('$chatroom')");
				$this->db->query("CREATE TABLE $chatroom ( id int NOT NULL AUTO_INCREMENT PRIMARY KEY, sharename varchar(255) NOT NULL, secret varchar(255) NOT NULL,username varchar(255) NOT NULL)");
                $this->db->commit();
            }
        }

		function isExistsInRoom($chatroom,$sharename,$secret,$username) {
			$rs = $this->db->query("SELECT id FROM $chatroom WHERE sharename = '$sharename' AND secret = '$secret' AND username = '$username'");
			$this->db->commit();
            if($rs){
                $rs->data_seek(0);
                if($row = $rs->fetch_row()){
                    $ret = $row[0];
                    if($ret > 0)
                        return true;
                }
            }
            return false;
        }

		function getRowsInRoom($chatroom) {
			$rs = $this->db->query('SELECT count(1) FROM $chatroom');
			$this->db->commit();
            if($rs->num_rows > 0){
                $rs->data_seek(0);
                if( $rows = $rs->fetch_row() ){
                    $val = $rows[0];
                }
                return $val;
            }
            else
                return 0;
        }

		function insertInRoom($chatroom, $sharename, $secret, $username) {
            $check = $this->isExistsInRoom($chatroom,$sharename,$secret,$username);
			if( !$check ){
                $rs = $this->db->query("INSERT INTO $chatroom (sharename, secret, username) VALUES ('$sharename', '$secret', '$username')");
                $this->db->commit();
                if($rs)
                    return true;
                else
                    return false;
			}
            else
                return true;
        }

		function getUsersFromRoom($chatroom,$sharename,$secret,$username) {
			$rs = $this->db->query("SELECT username FROM $chatroom WHERE sharename='$sharename' AND secret = '$secret' AND username != '$username'");
            $this->db->commit();
			if( !$rs ) {
                return 0;
			}
            while( $row = $rs->fetch_row() ){
                $arr[] = $row[0];
            }
            return $arr;
		}
	}
?>

<?php
	$DBServer = '127.0.0.1';
	$DBUser   = 'root';
	$DBPass   = 'jshjso1116';
	$DBName   = 'chatdb';
	error_reporting(E_ALL);
	$socket = socket_create(AF_INET, SOCK_STREAM, 0);
	if ($socket === false) {
		echo "socket_create() failed: reason: ".socket_strerror(socket_last_error())."\n";
	} else {
		echo "OK.\n";
	}
	
	$result = socket_connect($socket, '192.168.2.13', 50000);
	if ($result === false) {
		echo "socket_connect() failed.\nReason: ($result) ".socket_strerror(socket_last_error($socket)) . "\n";
	} else {
		echo "socket_connect OK.\n";
	}

	$conn = mysqli_connect($DBServer, $DBUser, $DBPass, $DBName);
	$sql = 'SELECT * FROM friends';
	$rs = $conn->query($sql);
	if($rs === false) {
		trigger_error('Wrong SQL: '.$sql.' Error: '.$conn->error, E_USER_ERROR);
	}
	else {
        $row = $rs->fetch_row();
        echo "database connected\n";
	}
	$rs->data_seek(0);
    $in = "iam::friends::";
	$in .= $row[1]."::".$row[2]."::".$row[3];
    echo $in."\n";
	if( ! socket_send ( $socket , $in , strlen($in) , 0)){
		$errorcode = socket_last_error();
		$errormsg = socket_strerror($errorcode);
		die("Could not send data: [$errorcode] $errormsg \n");
	}
	echo "Message send successfully \n";
	//Now receive reply from server
	if(socket_recv ( $socket , $buf , 2045 , MSG_WAITALL ) === FALSE){
		$errorcode = socket_last_error();
		$errormsg = socket_strerror($errorcode);
		die("Could not receive data: [$errorcode] $errormsg \n");
	}
	//print the received message
	echo "Closing socket...".$buf."\n";
	socket_close($socket);
	echo "OK.\n\n";
?>

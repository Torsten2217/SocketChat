<?php
    //$address = "";
	$address = "192.168.2.13";
	$port = 50000;
	$fp = fsockopen($address, $port);
	if ($fp) {
		// port is open and available
		fclose($fp);
		exit(0);
	}
	else {
		// port is closed or blocked
		include "database.php";
	    $api = new RedeemAPI;
		error_reporting(~E_NOTICE);
		set_time_limit (0);	
		$max_clients = 20;
		if(!($sock = socket_create(AF_INET, SOCK_STREAM, 0)))
		{
			$errorcode = socket_last_error();
			$errormsg = socket_strerror($errorcode);
			die("Couldn't create socket: [$errorcode] $errormsg \n");
		}
		echo "Socket created \n";
		// Bind the source address
		if( !socket_bind($sock, $address , $port) ){
			$errorcode = socket_last_error();
			$errormsg = socket_strerror($errorcode);
			die("Could not bind socket : [$errorcode] $errormsg \n");
		}
		echo "Socket bind OK \n";
		if(!socket_listen($sock, 20))
		{
			$errorcode = socket_last_error();
			$errormsg = socket_strerror($errorcode);
			die("Could not listen on socket : [$errorcode] $errormsg \n");
		}
		echo "Socket listen OK \n";
		echo "Waiting for incoming connections... \n";
		//array of client sockets
		$client_socks = array();
		//array of sockets to read
		$read = array();
		//start loop to listen for incoming connections and process existing connections
		while (true){
			//prepare array of readable client sockets
			$read = array();
			//first socket is the master socket
			$read[0] = $sock;
			//now add the existing client sockets
			for ($i = 0; $i < $max_clients; $i++){
				if($client_socks[$i] != null){
					$read[$i+1] = $client_socks[$i];
				}
			}
			//now call select - blocking call
			if(socket_select($read , $write , $except , null) === false){
				$errorcode = socket_last_error();
				$errormsg = socket_strerror($errorcode);
				die("Could not listen on socket : [$errorcode] $errormsg \n");
			}
			//if ready contains the master socket, then a new connection has come in
			if (in_array($sock, $read)){
				for ($i = 0; $i < $max_clients; $i++){
					if ($client_socks[$i] == null){
						$client_socks[$i] = socket_accept($sock);
						//display information about the client who is connected
						if(socket_getpeername($client_socks[$i], $address, $port)){
							echo "Client $address : $port is now connected to us. \n";
						}
						break;
					}
				}
			}
			//check each client if they send any data
			for ($i = 0; $i < $max_clients; $i++){
				if (in_array($client_socks[$i] , $read)){
					$input = socket_read($client_socks[$i] , 1024);
					if ($input == null) {
						//zero length string meaning disconnected, remove and close the socket
						unset($client_socks[$i]);
						socket_close($client_socks[$i]);
					}
					else{
						$trimdata = trim($input);
						$token = explode("::",$trimdata);
						$count = count($token);
						if( $count == 5 ){
							if( $token[0] == "iam" ){
								$api->createChatRoom($token[1]);
								$success = $api->insertInRoom($token[1],$token[2],$token[3],$token[4]);
								if($success){
									$users = $api->getUsersFromRoom($token[1],$token[2],$token[3], $token[4]);
	                                $all = implode("::", $users);//users list
	                                $all = "ok::".$all;
									socket_write($client_socks[$i], $all, strlen($all));						
								}
								else{
									socket_write($client_socks[$i], "no::");
								}
							}
							else{//msg - send it to the other clients
								for ($j = 0; $j < $max_clients; $j++) {
									if (isset($client_socks[$j]) && $j != $i) {
										$other = socket_read($client_socks[$j] , 1024);
										$othertrim = trim($other);
										$othertoken = explode("::",$othertrim);
										$othercount = count($othertoken);
										if( $othercount == 5 && $othertoken[0] == "msg" && $token[1] == $othertoken[1] && $token[2] == $othertoken[3]){
											socket_write($client_socks[$j], $token[4], strlen($token[4]));
										}
									}
								}
							}
						}
						else{
							if ($trimdata == 'exit') {
								// requested disconnect
								socket_close($client_socks[$i]);
							}
							else{
								socket_write($client_socks[$i], "err::");
							}
						}				
					}
				}
			}
		}
	    unset($api);
	    socket_close($sock);
	}
?>
<?php
$url = 'uploads/';
if (!is_dir($url)) {
    mkdir($url, 0755, true);
}

$subdir = '';
if (isset($_GET['subdir'])) {
    $subdir = $_GET['subdir'];
}
if (isset($_POST['subdir'])) {
    $subdir = $_POST['subdir'];
}

if($subdir!='') {
    $url .= $subdir."/";
    if (!is_dir($url)) {
        mkdir($url, 0755, true);
    }
    
}

if (isset($_POST['ie']) && $_POST['ie'] == true) {
    
    $response = array();
    
    for ($i = 0; $i < sizeof($_FILES['file']['name']); $i++) {
        if (strlen($_FILES['file']['name'][$i]) > 0) {
            $success = move_uploaded_file($_FILES['file']['tmp_name'][$i],
                    $url . $_FILES['file']['name'][$i]);
            
            // Buidling the response json object
            $response[$i]['name'] = $_FILES['file']['name'][$i];
            $response[$i]['size'] = $_FILES['file']['size'][$i];
            $response[$i]['type'] = $_FILES['file']['type'][$i];
            $response[$i]['url'] = $url.$_FILES['file']['name'][$i];
            $response[$i]['description'] = $_POST['description'][$i];
            
            if (!$success) {
                $response[$i]['uploaded'] = false;
            } else {
                $response[$i]['uploaded'] = true;
            }
        }
    }
    
    echo __json_encode($response);
    
} else {
    
    $content = file_get_contents('php://input');
    $headers = getallheaders();
    $headers = array_change_key_case($headers, CASE_UPPER);
    
    $response = array('url' => $url.$headers['FILENAME']);

    if (file_put_contents($url . $headers['FILENAME'], $content)) {
        $response['status'] = 'success';
    } else {
        $response['status'] = 'error';
    }
    
    // ie fix to handle json response
    header("Content-Type: text/plain");
    echo __json_encode($response);
}

/*
 * The CentOS php version doesn't support json_encode
 * so we provide our own.
 */
function __json_encode( $data ) {            
    if( is_array($data) || is_object($data) ) { 
        $islist = is_array($data) && ( empty($data) || array_keys($data) === range(0,count($data)-1) ); 
        
        if( $islist ) { 
            $json = '[' . implode(',', array_map('__json_encode', $data) ) . ']'; 
        } else { 
            $items = Array(); 
            foreach( $data as $key => $value ) { 
                $items[] = __json_encode("$key") . ':' . __json_encode($value); 
            } 
            $json = '{' . implode(',', $items) . '}'; 
        } 
    } elseif( is_string($data) ) { 
        # Escape non-printable or Non-ASCII characters. 
        # I also put the \\ character first, as suggested in comments on the 'addclashes' page. 
        $string = '"' . addcslashes($data, "\\\"\n\r\t/" . chr(8) . chr(12)) . '"'; 
        $json    = ''; 
        $len    = strlen($string); 
        # Convert UTF-8 to Hexadecimal Codepoints. 
        for( $i = 0; $i < $len; $i++ ) { 
            
            $char = $string[$i]; 
            $c1 = ord($char); 
            
            # Single byte; 
            if( $c1 <128 ) { 
                $json .= ($c1 > 31) ? $char : sprintf("\\u%04x", $c1); 
                continue; 
            } 
            
            # Double byte 
            $c2 = ord($string[++$i]); 
            if ( ($c1 & 32) === 0 ) { 
                $json .= sprintf("\\u%04x", ($c1 - 192) * 64 + $c2 - 128); 
                continue; 
            } 
            
            # Triple 
            $c3 = ord($string[++$i]); 
            if( ($c1 & 16) === 0 ) { 
                $json .= sprintf("\\u%04x", (($c1 - 224) <<12) + (($c2 - 128) << 6) + ($c3 - 128)); 
                continue; 
            } 
                
            # Quadruple 
            $c4 = ord($string[++$i]); 
            if( ($c1 & 8 ) === 0 ) { 
                $u = (($c1 & 15) << 2) + (($c2>>4) & 3) - 1; 
            
                $w1 = (54<<10) + ($u<<6) + (($c2 & 15) << 2) + (($c3>>4) & 3); 
                $w2 = (55<<10) + (($c3 & 15)<<6) + ($c4-128); 
                $json .= sprintf("\\u%04x\\u%04x", $w1, $w2); 
            } 
        } 
    } else { 
        # int, floats, bools, null 
        $json = strtolower(var_export( $data, true )); 
    } 
    return $json; 
} 
?>

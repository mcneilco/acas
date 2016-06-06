<?php
// PHP doesn't handle PUT input so we have to do this:
parse_str(file_get_contents("php://input"),$put_vars);

if(strpos($_POST['metaLotToSave'], 'forceerror') !== false || strpos($put_vars['metaLotToSave'], 'forceerror') !== false) {
    header('lot save error', true, 506);
    echo '{"errors":[{"level":"error","message": "Parent with matching sturcture and stereo category exists" }]}';
} else {
    header("Content-type: application/json;charset=utf-8");
    echo '{"id":101, "corpName":"SGD-9999-K-3"}';
}

?>

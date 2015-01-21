<?php
/**
 * 处理创建,合并入种子信息 _vars.inf
 * 处理编辑，合并入种子信息
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/1/21
 * Time: 10:39
 */

require_once dirname(__FILE__) . "/inc.php";

$appID = input('appID');

$projectName = 'app'.$appID;
if($appID == "")
{
    die("AppID，路径不可以为空");
}
## 输出路径
$projectOutFolder = GENERATOED_ROOT . '/' . $projectName;
@mkdir($projectOutFolder);


#写入种子
writeSeed($_POST,$projectOutFolder . "/_vars.inf");

    header("location:./upload.php?id=".$appID);
    die();
?>
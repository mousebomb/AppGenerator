<?php
/**
 * 列出目录下 已经有种子的项目
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/1/19
 * Time: 22:44
 */
require_once dirname(__FILE__) . "/inc.php";

?><!DOCTYPE html>
<html>
<head>
    <title>Aoao游戏创建工具</title>
    <link rel="stylesheet" href="css/style.css"/>
    <link rel="stylesheet" href="css/general.css"/>
    <link rel="stylesheet" href="css/extra.css"/>

</head>
<body>

<h1>App 列表</h1>

<a href="create.php">创建新App</a>

<form action="" id="form2">
    <h2>已有的App</h2>


    <?php
    $foldersInPublish = scandir(GENERATOED_ROOT);
    foreach ($foldersInPublish as $folder) {
        if ($folder == "." || $folder == "..") continue;
        if (is_dir(GENERATOED_ROOT . "/" . $folder)) {
            $projectOutFolder = GENERATOED_ROOT . "/" . $folder;
            $seedFile = $projectOutFolder."/_vars.inf";
            if(file_exists($seedFile))
            {
                $autoFillData = readSeed($seedFile);
                $appID = $autoFillData['appID'];
                $appName = $autoFillData['zhName'];
                echo sprintf('<a href="edit.php?id=%d">%d : %s</a><br/>', $appID, $appID,$appName);
            }

        }


    }

    ?>
</form>
</body>
</html>
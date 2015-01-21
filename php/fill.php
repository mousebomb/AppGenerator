<?php
/**
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/1/20
 * Time: 22:20
 */
require_once dirname(__FILE__) . "/inc.php";

$appID=input('id');

$autoFillData=readSeedByAppID($appID);


?><!DOCTYPE html>
<html>
<head>
    <title>编辑App数据</title>
    <link rel="stylesheet" href="css/style.css"/>
    <link rel="stylesheet" href="css/general.css"/>
    <link rel="stylesheet" href="css/extra.css"/>

</head>
<body>

<div id="main-menu">
    <a href="edit.php?id=<?php echo $appID; ?>">1.基本信息</a>
    <a href="fill.php?id=<?php echo $appID; ?>">2.填入模板配置</a>
    <a href="upload.php?id=<?php echo $appID; ?>">3.上传素材文件</a>
    <a href="publish.php?id=<?php echo $appID; ?>">4.编译与发布</a>
</div>


<h1>填入模板配置</h1>
<form action="fill-handle.php" method="post">

    <input name="appID" type="hidden" value="<?php echo $appID; ?>"/>
    <h2>模板变量</h2>
    <table>
        <?php
        $fillvarsList = getTemplateFillvarsList($autoFillData['template']);

        foreach ($fillvarsList as $eachKey => $eachVO)
        {
            $eachLabel = $eachVO['label'];
            $eachPlaceholder    =$eachVO['placeholder'];
?>
            <tr>
                <td><?php echo $eachLabel; ?></td>
                <td><input type="text" name="<?php echo $eachKey; ?>" placeholder="<?php echo $eachPlaceholder; ?>"
                           id="" value="<?php echo $autoFillData[$eachKey]; ?>" /></td>
            </tr>

        <?php
        }


        ?>
    </table>

    <input type="submit" value="保存并下一步"/>

</form>
</body>
</html>
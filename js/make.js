window.onload = function()
{
    document.getElementById('makeButton').onclick = function ()
    {
        makeQuiz();
    }
}

function makeQuiz() {
    probDiv = document.getElementById("problem");
    aDiv = document.getElementById("a");
    bDiv = document.getElementById("b");
    cDiv = document.getElementById("c");
    dDiv = document.getElementById("d");
    expDiv = document.getElementById("explanation");

    if(existEmptyInput(probDiv,aDiv,bDiv,cDiv,dDiv))
    {
        alert ("入力されていない項目があります（解説以外は必須項目です）")
        return;
    }

    //全て入力されている場合，サーバーにリクエストを投げる
}

function existEmptyInput(prob,a,b,c,d)
{
    return (!prob.value || !a.value || !b.value || !c.value || !d.value);
}
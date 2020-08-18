window.onload = function()
{
    document.getElementById('solveProblem').onclick = function ()
    {
        SolveClicked();
    }
    document.getElementById('makeProblem').onclick = function ()
    {
        makeClicked();
    }
}

function SolveClicked()
{
    window.location.href = "quiz4/html/quiz.html";
}

function makeClicked()
{
    window.location.href = "quiz4/html/makequiz.html";
}
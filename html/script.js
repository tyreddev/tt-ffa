window.addEventListener('message', function (event) {
    var item = event.data;
    if (item.action === "show") {
        document.getElementById("container").style.display = "flex";
    } else if (item.action === "hide") {
        document.getElementById("container").style.display = "none";
    }
});

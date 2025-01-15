let translate = {
    fillCan: "Rellenar Bidón",
    buyCan: "Comprar Bidón",
};

window.addEventListener("message", function(event) {
    const item = event.data;

    if (!item || typeof item !== "object") return;

    switch (item.type) {
        case "status":
            if (item.status) {
                $(".pumpDisplay").fadeIn("fast");
            } else {
                $(".pumpDisplay").fadeOut("slow");
            }
            break;

        case "mainMenu":
            $(".mainMenu").fadeIn("fast");
            $("#jerryButtonSpan").text(item.jerryCan ? translate.fillCan : translate.buyCan);
            break;

        case "close":
            $(".mainMenu").fadeOut("slow");
            break;

        case "update":
            $(".fuelCurrency").text(item.fuelCost);
            $(".fuelPrecentage").text(item.fuelTank);
            break;

        case "warn":
            $(".fuelCurrency").addClass("flashRed");
            setTimeout(() => $(".fuelCurrency").removeClass("flashRed"), 1000);
            break;
    }
});

document.getElementById("jerryButton")?.addEventListener("click", function() {
    $.post("https://dsco_fuel/jerrycan", JSON.stringify({}));
});

document.getElementById("fuelButton")?.addEventListener("click", function() {
    $.post("https://dsco_fuel/fuel", JSON.stringify({}));
});

document.getElementById("cancelButton")?.addEventListener("click", function() {
    $.post("https://dsco_fuel/exit", JSON.stringify({}));
});

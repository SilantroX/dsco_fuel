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

        case "lang":
            $("#jerryTranslate").text(item.translate.JerryCan);
            $(".fuelPriceSpan").text(item.FuelPrice);
            $("#titleTranslate").text(item.translate.Title);
            $("#welcomeTranslate").text(item.translate.Welcome);
            $("#pumpButtonSpan").text(item.translate.Fuel);
            $("#closeButtonSpan").text(item.translate.Close);
            $("#jerryButtonSpan").text(item.translate.JerryCanButton);
            break;
    }
});

document.getElementById("jerryButton")?.addEventListener("click", function() {
    $.post(`https://${GetParentResourceName()}/jerrycan`, JSON.stringify({}));
});

document.getElementById("fuelButton")?.addEventListener("click", function() {
    $.post(`https://${GetParentResourceName()}/fuel`, JSON.stringify({}));
});

document.getElementById("cancelButton")?.addEventListener("click", function() {
    $.post(`https://${GetParentResourceName()}/exit`, JSON.stringify({}));
});

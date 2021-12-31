import "reflect-metadata";
import {createConnection} from "typeorm";
import {Card} from "./entity/Card";


createConnection().then(async connection => {

    console.log("Inserting a new card into the database...");
    const card = new Card();
    card.name = " Angel of Mercy"
    card.artist = "Volkan";
    card.text = "Target creature gets +3/+3 and gains flying until end of turn. (It can't be blocked except by creatures with flying or reach.)";
    await connection.manager.save(card);


    console.log("Saved a new card with id: " + card.id);

    console.log("Loading cards from the database...");
    const cards = await connection.manager.find(Card);

    console.log("Loaded cards: ", cards);

    console.log("Here you can setup and run express/koa/any other framework.");

}).catch(error => console.log(error));

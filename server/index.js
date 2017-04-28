const express = require( "express" );
const { json } = require( "body-parser" );
const cors = require( "cors" );
const { createStore } = require( "redux" );

const { gifs, voteForGif } = require( "./gifs" );

const port = 4444;
const app = express();
const store = createStore( gifs );

app.use( json() );
app.use( cors() );

app.post( "/api/vote", ( { body: { url } }, res ) => {
	store.dispatch( voteForGif( url ) );

	res.status( 200 ).json( { success: true } );
} );

app.listen( port, () => console.log( `Express listening on ${ port }` ) );

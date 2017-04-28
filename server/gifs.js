// lol totally unnecessary redux
const VOTE_FOR_GIF = "VOTE_FOR_GIF";

const initialState = {
	gifs: []
};

function gifs( state = initialState, action ) {
	switch ( action.type ) {
		case VOTE_FOR_GIF: {
			const gifIndex = state.gifs.findIndex( ( { url } ) => url === action.url );

			if ( gifIndex >= 0 ) {
				const gif = state.gifs[ gifIndex ];
				return {
					gifs: [
						  ...state.gifs.slice( 0, gifIndex )
						, Object.assign( {}, gif, { votes: gif.votes + 1 } )
						, ...state.gifs.slice( gifIndex + 1, state.gifs.length )
					]
				};
			}
			return { gifs: [ ...state.gifs, { url: action.url, votes: 1 } ] };
		}
	}
}

function voteForGif( url ) {
	return { type: VOTE_FOR_GIF, url };
}

module.exports = { gifs, voteForGif };

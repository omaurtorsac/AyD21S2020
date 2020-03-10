/**
 * Created by mauro on 31/12/17.
 */
function nobackbutton(){
    window.location.hash="no-back-button";
    window.location.hash="Again-No-back-button"
    window.onhashchange=function(){window.location.hash="no-back-button";}
}
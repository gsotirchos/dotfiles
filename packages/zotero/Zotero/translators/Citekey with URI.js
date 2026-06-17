{
    "translatorID":"8dbf9b92-f796-4153-8f2e-ac6c157500dc",
    "translatorType":2,
    "label":"Citekey with URI",
    "creator":"Silent",
    "target":"markdown",
    "minVersion":"2.0",
    "maxVersion":"",
    "priority":200,
    "inRepository":false,
    "lastUpdated":"2024-06-17"
}


function doExport() {
    var item;

    while(item = Zotero.nextItem()) {
        // var date = Zotero.Utilities.strToDate(item.date).year;
        // var year = date && !isNaN(date) ? date + ". " : (typeof item.date == 'undefined'?  "" : item.date + ". ");
        // var library_id = item.libraryID ? item.libraryID : "";
        // var author_lastname = getValidAuthor(item);
        // var title = item.title ? "*" + item.title + "*" : "";
        // var key = item.key;
        var citekey = item.citationKey ? `@${item.citationKey}` : "";

        Zotero.write(`[${citekey}](zotero://select/items/${citekey})`);
    }
}

// function getValidAuthor(item){
//     if(item.creators && item.creators[0] && item.creators[0].lastName){
//         return item.creators[0].lastName + ". ";
//     }else{
//         return "";
//     }
//
// }

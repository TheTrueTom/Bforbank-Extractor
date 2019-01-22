function handleExtensionMessage()
{
    var accountNumber = document.getElementsByClassName("num-compte")[0].innerHTML.toString().replace('Compte n° ','');
    
    console.log("Extracting operations table");
    var operationsTable = document.getElementsByClassName("style-operations")[0];
    
    console.log("Extracting operations");
    var operations = operationsTable.getElementsByTagName("tbody")[0];
    
    console.log("Extracting operations details");
    var operationsDetails = operations.getElementsByTagName("tr");
    
    console.log("Creating empty array");
    var allOperations = [];
    
    console.log("Creating empty vars");
    var date = "";
    var amount = "";
    var details = "";
    
    console.log("Looping over operations");
    for (var i=0, max=operationsDetails.length; i<max; i++) {
        var currentTR = operationsDetails[i];
        
        if (currentTR.className == "tr-section") {
            date = currentTR.getElementsByTagName("th")[0].innerHTML.toString().replace(/<span>|<\/span>|<p>|<\/p>|\t|\n/g, '').replace('<i class=\"fa fa-calendar\"></i> Opérations du ', '').replace(/^(?=\n)$|^\s*|\s*$|\n\n+/gm,'');
        } else if (currentTR.className == "tr-trigger send-tc-submit") {
            amount = currentTR.getElementsByTagName("td")[1].innerHTML.toString().replace(/<span>|<\/span>|<p>|<\/p>|\t|\n/g, '').replace('&nbsp;€', '').replace(/^(?=\n)$|^\s*|\s*$|\n\n+/gm,'');
        } else if (currentTR.className == "tr-more") {
            details = currentTR.getElementsByTagName("td")[0].innerHTML.toString().replace(/<span>|<\/span>|<p>|<\/p>|\t/g, '').replace(/^(?=\n)$|^\s*|\s*$|\n\n+/gm,'').replace(/\n\n/gm, '');
            console.log(details)
            
            var operation = [date, amount, details];
            allOperations.push(operation);
        }
    }
    
    console.log("Sending result");
    safari.extension.dispatchMessage("Source", {"operations": allOperations, "accNumber": accountNumber});
}

function injectedSetup()
{
    safari.self.addEventListener("message", handleExtensionMessage);
}

document.addEventListener("DOMContentLoaded", function(event) {
    injectedSetup();
});

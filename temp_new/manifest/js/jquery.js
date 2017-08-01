
function function updateCandidatesList(){
   var jsonService_base="/addCandidate.php?";year=2016;
   state=$("select#cstateid option").filter(":selected").val();
   state_name=$("select#cstateid option").filter(":selected").text();
   party_group=$("select#cstateid option").filter(":selected").val();
   query="state="+state;
   image="http://presidentials.mytimetovote.com/images/"+year+"/"+state+".png";
   var url=jsonService_base+"&t=1&"+query;
   image="<img src='"+image+"' alt='"+state_name+" Candidates by Party'/>";
   $('#resultsImage').html(image);
    $.getJSON(url,function(data) {
     var theTable = document.getElementById("candidatesList");
     //clear table first
     //
     $("#candidatesList tr").remove();
     i=0;
     var row= theTable.insertRow(0);
     var cell1=row.insertCell(0);
     var cell2=row.insertCell(1);
     var cell3=row.insertCell(2);
     var cell4=row.insertCell(3);
     //// Add some text to the new cells:
     cell1.innerHTML = "Candidate";
     cell2.innerHTML = "Home Residence";
     cell3.innerHTML = "Date Filed";
     cell4.innerHTML = "Party Affiliation";
     $.each(data["candidates"], function(index, val) {
          name=val.candidate.name;year=val.candidate.year;city=val.candidate.city;
          month=val.candidate.month;day=val.candidate.day;party=val.candidate.party;
          ++i;
          row=theTable.insertRow(i);
          cell1=row.insertCell(0);cell2=row.insertCell(1);
          cell3=row.insertCell(2);cell4=row.insertCell(3);
          cell1.innerHTML = name;
          cell2.innerHTML = city+","+state_name;
          cell3.innerHTML = month+"/"+day+"/"+year;
          cell4.innerHTML = party;
      });
      var rows = theTable.getElementsByTagName("tr");
      for(i = 0; i < rows.length; i++){
        if(i % 2 == 0)rows[i].className = "tgray";
      }
      theTable.style.display="table";
    });
}


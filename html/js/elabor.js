function onElement() {

	var a = arguments[0].split(",");
	var b = arguments[1].split(";");
	var ia = a.length;
	var ib = b.length;
	for ( var i = 0; i < ib; i++) {
		var sid = b[i].substring(2,6);
		var gid = b[i].substring(3,6);
		var wid = "t" + gid;
		document.getElementById(wid).value = b[i];
	}
	for ( var i = 0; i < ia; i++) {
		document.getElementById(a[i]).bgColor = "#e6ffc2";
	}

}

function setcolor(a,b,c,d,e,f) {

	var mm =  document.getElementById(c).value + "\," + a + "\," + e ;
	var arpg = ["cc01", "ll01", "cc02", "ll02", "dd01"];
	var artpg = ["tc01", "tl01", "tc02", "tl02", "td01"];
	document.getElementById(a).bgColor = "#e6ffc2";
	var cells = document.getElementsByName(d);
        var x = parseInt(e.substring(0,1));
	var y = x * 10000;
	for (var i = 0; i < f; i++)
        {
		var w = y + i;
		if ( w != e ) {
                        document.getElementById(w).bgColor = "white";
                }
	}
	for (var i = 0; i < cells.length; i++)
	{
		var z = cells[i].getAttribute('id');
  		if ( z != e ) {
			document.getElementById(z).bgColor = "white";
		} else {
			document.getElementById(z).bgColor = "#e6ffc2";
			document.getElementById(b).value = mm;
		}
		
	}
	for ( var yy = 0; yy < 5; yy++ ) {
		var zz = 0;
		var xx = yy + 1;
		var y = xx * 10000;
		for (var i = 0; i < f; i++) {
			var ww = y + i;
			var colr = document.getElementById(ww).bgColor;
			if ( colr == "white" ) {
				zz += 1;
			}
		}
		if ( zz == f ) {
			var wz = xx -1;
			document.getElementById(arpg[wz]).bgColor = "white";
			document.getElementById(artpg[wz]).value = '';
		}
	}
	//document.getElementById('lst').value = mm; 
	//var bb = ww + " " + zz + " " + f + " " + wz;
	//window.alert(bb);
	//document.getElementById('inf').innerHTML = '';
	//for ( var i = 0; i < artpg.length; i++)
        //{
	//	document.getElementById('inf').innerHTML += document.getElementById(artpg[i]).value + " " + artpg[i];
	//}


}

function chancolor(a,b) {

//	document.getElementById(b).borderColor = "gray";
        if (document.getElementById(a).bgColor != "#e6ffc2") {
        	document.getElementById(a).bgColor = "gray";
	} else {
		document.getElementById(b).border = '1';
	}

}

function flashcolor(a,b) {

	if (document.getElementById(a).bgColor != "#e6ffc2") {
        	document.getElementById(a).bgColor = "white";
	} else {
		document.getElementById(b).className = null;
	}

}

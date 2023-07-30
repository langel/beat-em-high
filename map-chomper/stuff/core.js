
let tohex = (x) => x.toString(16).padStart(2, '0'); 

const br = "<br>";
let output;

const process = (file, data) => {
	data = JSON.parse(data);
	console.log(data);
	const map_w = data.width;
	const map_h = data.height;
	data = data.layers[0].data;
	let table = 'map_data_0_table:\n';
	for (let x = 0; x < map_w; x++) {
		let line = '';
		for (let y = 0; y < map_h; y++) {
			let val = data[x + y * map_w];
			val--;
			if (val > 255) val = 0;
			line += tohex(val);
		}
		table += ' hex ' + line + '\n';
	}
	output.innerHTML = '<pre>' + table + '</pre>';
}

window.addEventListener("DOMContentLoaded", () => {
	const droptarg = document;
	const cont = document.getElementById("containment");
	const domp = new DOMParser();
	output = document.getElementById("output");
	// drop handler
	droptarg.addEventListener("drop", (e) => {
		e.preventDefault();
		cont.classList.remove("dragover");
		output.innerHTML = '';
		[...e.dataTransfer.items].forEach((item, i) => {
			if (item.kind === 'file') {
				const file = item.getAsFile();
				const r = new FileReader();
				//r.readAsArrayBuffer(file);
				//r.readAsBinaryString(file);
				r.readAsText(file);
				r.onload = () => {
					process(file, r.result);
				};
			}
		});
	});
	// drag hover
	droptarg.addEventListener("dragover", (e) => {
		e.preventDefault();
		cont.classList.add("dragover");
	});
	// drag end
	droptarg.addEventListener("dragleave", (e) => {
		e.preventDefault();
		cont.classList.remove("dragover");
	});
	console.log('core intiialized');
});

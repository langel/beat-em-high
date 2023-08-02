
let tohex = (x) => x.toString(16).padStart(2, '0'); 

const br = "<br>";
let output;

const process_json = (data) => {
	// XXX deprecated as we aren't using tiled any longer
	data = JSON.parse(data);
	console.log(data);
	spew(data.layers[0].data.map(x => x - 1), data.width, data.height);
}

const process_map = (data) => {
	console.log(data);
	spew(data, data[data.length - 4], data[data.length - 2]);
}

const spew = (data, map_w, map_h) => {
	let table = 'map_0_tiles:\n';
	console.log(map_w + ' ' + map_h);
	// map tiles
	for (let x = 0; x < map_w; x++) {
		let line = '';
		for (let y = 2; y < map_h; y++) {
			let val = data[x + y * map_w];
			if (val > 255) val = 0;
			line += tohex(val);
		}
		table += ' hex ' + line + '\n';
	}
	// map attributes
	table += '\nmap_0_attributes:\n';
	const attr_offset = map_w * map_h;
	const attr_w = Math.ceil(map_w / 4);
	const attr_h = Math.ceil(map_h / 4);
	console.log(attr_w + ' ' + attr_h);
	for (let x = 0; x < attr_w; x++) {
		let line = '';
		for (let y = 0; y < attr_h; y++) {
			console.log(attr_offset + x + y * attr_w);
			let val = data[attr_offset + x + y * attr_w];
			line += tohex(val);
		}
		console.log(line);
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
				//r.readAsBinaryString(file);
				console.log(file);
				if (file.name.includes('.json')) {
					r.readAsText(file);
					r.onload = () => process_json(r.result);
				}
				if (file.name.includes('.map')) {
					r.readAsArrayBuffer(file);
					r.onload = () => process_map(new Uint8Array(r.result));
				}
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

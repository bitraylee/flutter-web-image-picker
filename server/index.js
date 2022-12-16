const express = require("express")
const cors = require("cors")
const http = require("http")
const fs = require("fs")
const multer = require("multer")
const path = require("path")

const app = express()
const port = 5000

app.use(cors())
app.use((req, res, next) => {
	res.header("Access-Control-Allow-Origin", "*")
	res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization")
	next()
})

const diskStorage = multer.diskStorage({
	destination: (req, file, cb) => {
		cb(null, "./images")
	},
	filename: (req, _file, cb) => {
		const getFileName = (_file) => {
			const prefix = Date.now()
			const extName = _file ? path.extname(_file.originalname) : ".jpg"
			return prefix + extName
		}
		cb(null, getFileName())
	},
})

const upload = multer({
	storage: diskStorage,
})

app.get("/", (req, res) => {
	// fs.readFile("./assets/asset-1.jpg", (err, data) => {
	// 	if (err) throw err
	// 	res.writeHead(200, { "Content-Type": "image/jpeg" })
	// 	res.end(data)
	// })
	res.send("Hello there")
})

app.post("/image_upload", upload.single("image"), (req, res) => {
	if (req.file) {
		console.log("image found")
		res.send("File recieved")
	} else {
		console.log("image not found")
		res.status(400).send("Please upload a valid image")
	}
})

app.listen(port, () => {
	console.log(`Example app listening on port ${port}`)
})

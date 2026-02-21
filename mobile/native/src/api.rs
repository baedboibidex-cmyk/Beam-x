use std::net::{UdpSocket, TcpListener, TcpStream};
use std::time::Duration;
use std::io::{Read, Write};
use std::fs::File;
use serde::{Serialize, Deserialize};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Device {
    pub id: String,
    pub name: String,
    pub ip: String,
    pub port: u16,
}

pub fn get_version() -> String {
    "BeamX Core v0.1.0".to_string()
}

pub fn ping_device(device_id: String) -> String {
    format!("Pong from device: {}", device_id)
}

pub fn discover_devices() -> Vec<Device> {
    let socket = match UdpSocket::bind("0.0.0.0:54321") {
        Ok(s) => s,
        Err(_) => return vec![],
    };
    let _ = socket.set_broadcast(true);
    let _ = socket.set_read_timeout(Some(Duration::from_secs(2)));
    let _ = socket.send_to(b"BEAMX_DISCOVERY", "255.255.255.255:54321");
    let mut devices = vec![];
    let mut buf = [0; 1024];
    loop {
        match socket.recv_from(&mut buf) {
            Ok((len, addr)) => {
                let msg = String::from_utf8_lossy(&buf[..len]);
                if msg.starts_with("BEAMX_ACK") {
                    devices.push(Device {
                        id: format!("device_{}", addr.ip()),
                        name: "BeamX Device".to_string(),
                        ip: addr.ip().to_string(),
                        port: 54321,
                    });
                }
            }
            Err(_) => break,
        }
    }
    devices
}

// Start a TCP server to receive files
pub fn receive_file(save_path: String) -> String {
    let listener = match TcpListener::bind("0.0.0.0:54322") {
        Ok(l) => l,
        Err(e) => return format!("Error: {}", e),
    };
    println!("Waiting for file on port 54322...");
    match listener.accept() {
        Ok((mut stream, addr)) => {
            let mut file = match File::create(&save_path) {
                Ok(f) => f,
                Err(e) => return format!("Error creating file: {}", e),
            };
            let mut buf = [0; 4096];
            let mut total = 0usize;
            loop {
                match stream.read(&mut buf) {
                    Ok(0) => break,
                    Ok(n) => {
                        let _ = file.write_all(&buf[..n]);
                        total += n;
                    }
                    Err(_) => break,
                }
            }
            format!("Received {} bytes from {}", total, addr.ip())
        }
        Err(e) => format!("Error: {}", e),
    }
}

// Send a file to a target IP
pub fn send_file(file_path: String, target_ip: String) -> String {
    let mut file = match File::open(&file_path) {
        Ok(f) => f,
        Err(e) => return format!("Error opening file: {}", e),
    };
    let addr = format!("{}:54322", target_ip);
    let mut stream = match TcpStream::connect(&addr) {
        Ok(s) => s,
        Err(e) => return format!("Error connecting: {}", e),
    };
    let mut buf = [0; 4096];
    let mut total = 0usize;
    loop {
        match file.read(&mut buf) {
            Ok(0) => break,
            Ok(n) => {
                let _ = stream.write_all(&buf[..n]);
                total += n;
            }
            Err(_) => break,
        }
    }
    format!("Sent {} bytes to {}", total, target_ip)
}

// Send a chat message to a device
pub fn send_message(message: String, target_ip: String) -> String {
    use std::io::Write;
    let addr = format!("{}:54323", target_ip);
    match std::net::TcpStream::connect(&addr) {
        Ok(mut stream) => {
            let _ = stream.write_all(message.as_bytes());
            format!("Sent: {}", message)
        }
        Err(e) => format!("Error: {}", e),
    }
}

// Listen for incoming chat messages
pub fn receive_message() -> String {
    use std::io::Read;
    let listener = match std::net::TcpListener::bind("0.0.0.0:54323") {
        Ok(l) => l,
        Err(e) => return format!("Error: {}", e),
    };
    let _ = listener.set_nonblocking(false);
    match listener.accept() {
        Ok((mut stream, addr)) => {
            let mut buf = [0; 1024];
            match stream.read(&mut buf) {
                Ok(n) => {
                    let msg = String::from_utf8_lossy(&buf[..n]).to_string();
                    format!("{}|{}", addr.ip(), msg)
                }
                Err(e) => format!("Error: {}", e),
            }
        }
        Err(e) => format!("Error: {}", e),
    }
}

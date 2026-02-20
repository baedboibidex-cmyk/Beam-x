use flutter_rust_bridge::frb;
use std::net::UdpSocket;
use std::time::Duration;
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

    let broadcast_msg = "BEAMX_DISCOVERY";
    let _ = socket.send_to(broadcast_msg.as_bytes(), "255.255.255.255:54321");

    let mut devices = vec![];
    let mut buf = [0; 1024];

    loop {
        match socket.recv_from(&mut buf) {
            Ok((len, addr)) => {
                let msg = String::from_utf8_lossy(&buf[..len]);
                if msg.starts_with("BEAMX_ACK") {
                    devices.push(Device {
                        id: format!("device_{}", addr.ip()),
                        name: format!("BeamX Device"),
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

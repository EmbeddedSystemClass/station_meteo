id=0
sda=2
scl=1

-- initialize i2c, set pin1 as sda, set pin0 as scl
i2c.setup(0,sda,scl,i2c.SLOW)

for i=0,127 do
  i2c.start(id)
  resCode = i2c.address(id, i, i2c.TRANSMITTER)
  i2c.stop(id)
  if resCode == true then print("We have a device on address 0x" .. string.format("%02x", i) .. " (" .. i ..")") end
end
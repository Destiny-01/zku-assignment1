# Compile the merkel circom circuit
circom merkle.circom --r1cs --wasm --sym

cd merkel_js
# Generate our witness file
node generate_witness.js merkle.wasm ../input.json witness.wtns
# Start a new ceremony using powers of tau
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
# Contribute to the ceremony
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
# Finish the phase 1 of the ceremony and prepare for phase 2
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
# Use groth16 to generate our zkey
snarkjs groth16 setup ../merkle.r1cs pot12_final.ptau merkel_0000.zkey
# Contribute to our zkey
snarkjs zkey contribute merkle_0000.zkey merkle_0001.zkey --name="1st Contributor Name" -v
# Export the verification key
snarkjs zkey export verificationkey merkle_0001.zkey verification_key.json
# Generate our proof.json
snarkjs groth16 prove merkle_0001.zkey witness.wtns proof.json public.json

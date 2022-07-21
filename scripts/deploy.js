async function main() {
    const N11 = await ethers.getContractFactory("N11");
    const contract = await N11.deploy();
    console.log("Contract deployed to address:", contract.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

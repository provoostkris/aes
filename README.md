### AES
The design is an VHDL implementation of an AES algorithm as specified in the AES documents. 
As reference the FIPS 197 publication is used:
[FIPS 197](https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.197.pdf)

The code currently supports 
[vhdl](vhdl/) design files

```
aes_pkg.vhd          : a code package
galois_mul.vhd       : multiplications in galois field
key_expand.vhd       : key expansion for the cypher
sbox.vhd             : normal and inverse substitution
trf_addroundkey.vhd  : cypher transformation 'add round key'
trf_mixcolumns.vhd   : cypher transformation 'mix columns'
trf_shiftrows.vhd    : cypher transformation 'shift rows'
trf_subbytes.vhd     : cypher transformation 'substitute bytes'
```
[vhdl](bench/) test bench files

```
tb_aes.vhd              : core level test bench
tb_key_expand.vhd       : component level test bench
tb_trf_addroundkey.vhd  : component level test bench
tb_trf_mixcolumns.vhd   : component level test bench
tb_trf_shiftrows.vhd    : component level test bench
tb_trf_subbytes.vhd     : component level test bench
```

### dependencies
The code will work stand alone, compile in desired library and use as is.

### useage
The design can be used to study a possible implementation, based on the FIPS 197 publication. The code is 100 % synhtesizeable.
A reference project for [quartus](quartus/) is included: 

### User input
*SW(0) is used to reset the design.

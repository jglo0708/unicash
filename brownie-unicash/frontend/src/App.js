import * as React from 'react';
import { styled } from '@mui/material/styles';

import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell, { tableCellClasses } from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Paper from '@mui/material/Paper';



const StyledTableCell = styled(TableCell)(({ theme }) => ({
  [`&.${tableCellClasses.head}`]: {
    backgroundColor: theme.palette.common.black,
    color: theme.palette.common.white,
  },
  [`&.${tableCellClasses.body}`]: {
    fontSize: 14,
  },
}));

const StyledTableRow = styled(TableRow)(({ theme }) => ({
  '&:nth-of-type(odd)': {
    backgroundColor: theme.palette.action.hover,
  },
  // hide last border
  '&:last-child td, &:last-child th': {
    border: 0,
  },
}));

function createData(student, university, amount, chosen) {
  return { student, university, amount, chosen};
}
const rows = [
  createData('0x62eb3361aB5B6282FB63E75E290E3367c74BAD9D', "Bocconi", 30000, "False"),
  createData('0x62eb3361aB5B6282FB63E75E290E3367c74BAD9D', 'Stanford', 2000, "False"),
  createData('0xbc8337b84a2a221bCC3c4d2EfF254Fc781E3e8D7', "Harvard", 15000, "False"),
  createData('0xbc8337b84a2a221bCC3c4d2EfF254Fc781E3e8D7', "Cambridge", 16000, "False"),
  createData('0xbc8337b84a2a221bCC3c4d2EfF254Fc781E3e8D7', "Harvard", 12000, "True"),
];


export default function CustomizedTables() {
  return (
    <div>
      <h1>Welcome to UniCash Dashboard!</h1> 
      <div>
      <TableContainer component={Paper}>
      <Table  aria-label="customized table">
        <TableHead>
          <TableRow>
            <StyledTableCell align="left">Student</StyledTableCell>
            <StyledTableCell align="left"> University</StyledTableCell>
            <StyledTableCell align="left">Already donated ($)</StyledTableCell>
            <StyledTableCell align="left">University chosen? </StyledTableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {rows.map((row) => (
            <StyledTableRow key={row.student}>
              <StyledTableCell align="left">{row.student}</StyledTableCell>
              <StyledTableCell align="left">{row.university}</StyledTableCell>
              <StyledTableCell align="left">{row.amount}</StyledTableCell>
              <StyledTableCell align="left">{row.chosen}</StyledTableCell>
            </StyledTableRow>
          ))}
        </TableBody>
      </Table>
    </TableContainer>
      </div>
      
    </div>
    
  
    
    );
}
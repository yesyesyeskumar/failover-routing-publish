// import "./styles.css";


import React, { useState, useEffect } from 'react';
import {
  Table,
  Thead,
  Tbody,
  Tfoot,
  Tr,
  Th,
  Td,
  TableCaption,
  TableContainer,
} from '@chakra-ui/react'

function App() {
  const [userRecords, setUserRecords] = useState([]);
  const [awsRegion, setRegion] = useState("");

  useEffect(() => {
    fetchLambdaData();
  }, []);

  const fetchLambdaData = async () => {
    try {
      const response = await fetch(process.env.REACT_APP_API_URL);
      const data = await response.json();
      console.log(data)
      setUserRecords(data.body);
      setRegion(data.aws_region)
    } catch (error) {
      console.error('Error fetching data:', error);
    }
  };

  return (
    <TableContainer>
  <Table variant='striped' colorScheme='teal'>
    <TableCaption>User Records</TableCaption>
    <TableCaption><b>Region:</b> {awsRegion}</TableCaption>
    <Thead>
      <Tr>
        <Th>UserID</Th>
        <Th>UserName</Th>
        <Th>Name</Th>
        <Th>Email</Th>
        <Th>Status</Th>
      </Tr>
    </Thead>
    <Tbody>
    {userRecords.map((user, index) => (
            <Tr key={index}>
              <Td>{user.userId}</Td>
              <Td>{user.username}</Td>
              <Td>{user.name}</Td>
              <Td>{user.email}</Td>
              <Td>{user.status}</Td>
            </Tr>
          ))}
    </Tbody>
  </Table>
</TableContainer>





   
  );
}

export default App;









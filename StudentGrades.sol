pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
import "./UomToken.sol";
contract StudentGrades is UoMSupplyToken{
struct  Student { //Student characteristics
    string  name;
    string  lastname;
    string fname;
    string mname;
    uint birth_year;
    string specialization;
    uint register_year;
    mapping(bytes32 => uint8) grades; //the grades for each student. 
    /* it looks like that Student:
    name:"George"
    lastname:"Michoulis"
    fname:"D"
    mname:"S"
    birth_year:19--
    specialization:"AI"
    register_year:"2015"
    grades:{"class1 (in bytes32)":8, "class2":9, "class3":,5 ...}*/
    
}
mapping(address => mapping(uint8=>bytes32)) NameOfStudentGrades; // usefull to keep in memory the student classes (only the names) indexed. 


mapping(address =>Student) students; //keep the studens in memory
address[] public studentAccs; // keep the address of the student. usefull to check if the students allready exists.


mapping(address=>uint) CountOfGrades; //just to keep the number of the classes for a student.


//take all the data that is needed to store a student in storage, and then store his address for validation purpose
function  setStudent(address _address,string memory _name,string memory _lastname,string memory _fname,  string memory _mname,uint  _birth_year,uint  _register_year,string memory _specialization) public onlyOwner returns(bool succes) //its public because otherwise i can't give so many parameters in function
{ require(IfNotStudentExists(_address));
 
    students[_address].name=_name;
    students[_address].lastname=_lastname;
    students[_address].fname=_fname;
    students[_address].mname=_mname;
    students[_address].birth_year=_birth_year;
    students[_address].specialization=_specialization;
    students[_address].register_year=_register_year;
    studentAccs.push(_address);
    return true;
    
    
    
}
 function convertToInt(bytes32 b) public pure returns(uint8) { //bytes32 to uint and then to uin8 to be able to read it as natural number
        return uint8(uint(b));
    }
mapping(address=>uint) AvgOfStuddent; //leep the avgs of students
//setting the name of classes of the student and his grades.  create the average of his classes. summarize all the ects that he has and send them to his address
function  setStudentGrades(address _address,bytes32[] calldata _grades) external payable returns(bool)  {
    
    uint8 avg;
    uint8 ects;
    uint8 count;
    for(uint i=0;i<_grades.length-2; i+=3) 
    {   count++;
        uint8 grade=convertToInt(_grades[i+1]);
        students[_address].grades[_grades[i]]=uint8(grade);
        NameOfStudentGrades[_address][count-1]=_grades[i];
        avg+= uint8(grade);
        ects+=convertToInt(_grades[i+2]);
        
       
    }
   
    CountOfGrades[_address]=count;
    AvgOfStuddent[_address]=avg/count;
   transfer(_address,ects);
   return true;
    
}
//return's student's informations
function getStudent(address _address) view external   returns(string memory,  string memory, string memory, string memory,uint, string memory,uint)
{
    return( students[_address].name, students[_address].lastname,students[_address].fname,students[_address].mname,students[_address].birth_year,students[_address].specialization,students[_address].register_year);
}
//return's student's grades, ects and his avg
function getGradesOfStudent(address _address) view  external returns( bytes32[] memory ,uint8[] memory,uint,uint  ){
    bytes32[] memory nameofgrades= new bytes32[](CountOfGrades[_address]);
     uint8[] memory gradess=new uint8[](CountOfGrades[_address]); 
    for(uint8 i=0;i<CountOfGrades[_address];i++)
    {
            nameofgrades[i]=NameOfStudentGrades[_address][i];
            gradess[i]=students[_address].grades[nameofgrades[i]];
             
    }
    uint ects=UoMSupplyToken.balanceOf(_address);
    return (nameofgrades,gradess,ects,AvgOfStuddent[_address]);
}
//check if students allready exist, if not then send true and let his infromations to be stored
function IfNotStudentExists(address _address) internal view returns(bool){
    for(uint i=0;i<studentAccs.length;i++)
    {
    if(studentAccs[i]==_address){
        return false;
    }
}
    return true;
}

}

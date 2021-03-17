pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
import "./UoMtoken.sol";
contract StudentGrades is UoMSupplyToken{
struct  Student { //Student diploma
    string  name;
    string  lastname;
    string fname;
    string mname;
    string birth_year;
    string specialization;
    string register_year;
    mapping(string => uint8) grades; //the grades for each student. 
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
mapping(address => mapping(uint8=>string)) NameOfStudentGrades; // usefull to keep in memory the student classes (only the names) indexed. 


mapping(address =>Student) students; //keep the studens in memory
address[] public studentAccs; // keep the address of the student. usefull to check if the students allready exists.
mapping(address => uint8)ECTS;  // keep the ects of student.

mapping(address=>uint) CountOfGrades; //just to keep the number of the classes for a student.


//take all the data that is needed to store a student in storage, and then store his address for validation purpose
function  setStudent(address _address,string memory _name,string memory _lastname,string memory _fname,  string memory _mname,string memory _birth_year,string memory _register_year,string memory _specialization) public onlyOwner returns(bool succes) //its public because otherwise i can't give so many parameters in function
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
/* function convertToInt(bytes32 b) public pure returns(uint8) { //bytes32 to uint and then to uin8 to be able to read it as natural number
        return uint8(uint(b));
    }*/
mapping(address=>uint) AvgOfStuddent; //leep the avgs of students
//setting the name of classes of the student and his grades.  create the average of his classes. summarize all the ects that he has and send them to his address
function  setStudentGrades(address _address,string[] calldata gradesname, uint8[] calldata _grades) external payable returns(bool)  {
    
    uint8 avg;
    uint8 ects;
    uint8 count=0;
    for(uint8 i=0;i<_grades.length-1; i+=2) 
    {   
        uint8 grade=_grades[i];
        students[_address].grades[gradesname[count]]=grade;
        NameOfStudentGrades[_address][count]=gradesname[count];
        avg+= uint8(grade);
        ects+=_grades[i+1];
        count++;
       
    }
   
    CountOfGrades[_address]=count;
    AvgOfStuddent[_address]=avg/count;
   transfer(_address,ects);
   ECTS[_address]= ects;
   return true;
    
}
//return's student's informations
function getStudent(address _address) view public  returns(string memory,  string memory, string memory, string memory,string memory, string memory,string memory)
{
    return( students[_address].name, students[_address].lastname,students[_address].fname,students[_address].mname,students[_address].birth_year,students[_address].specialization,students[_address].register_year);
}
//return's student's grades, ects and his avg
function getGradesOfStudent(address _address) view  external returns( string[] memory ,uint8[] memory,uint,uint  ){
    string[] memory nameofgrades= new string[](CountOfGrades[_address]);
     uint8[] memory gradess=new uint8[](CountOfGrades[_address]); 
    for(uint8 i=0;i<CountOfGrades[_address];i++)
    {
            nameofgrades[i]=NameOfStudentGrades[_address][i];
            gradess[i]=students[_address].grades[NameOfStudentGrades[_address][i]];
             
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
function revoke (address _address) public {
    delete students[_address];
     
     
     for(uint8 i=0;i<CountOfGrades[_address];i++)
    {
            delete students[_address].grades[NameOfStudentGrades[_address][i]];
            delete NameOfStudentGrades[_address][i];
             
    }
    delete CountOfGrades[_address];
    delete AvgOfStuddent[_address];
    uint count =0;
     while (true){
         if(studentAccs[count] == _address)
            {delete studentAccs[count]; break;}
        else{count++;}
     }
     _burn(_address,ECTS[_address]);   
    }
function mint(address _address, uint8 ammount) payable public returns(bool){
    bool flag =false;
    flag=_mint(_address,ammount);
    return flag;
}
}

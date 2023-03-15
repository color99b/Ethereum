# Fundrasing 이란?

- 사전적 정의 : 특정 목적, 특히 자선 단체를 위해 돈을 모으거나 생산하는 행위.
- Ethereum 에서의 정의는 정확하진 않지만, 단위가 ether일 뿐 여러가지 nft, app 등을 배포 및 출시를 하기위해 후원금을 모으고, 목표금액을 달성하면 owner에게 금액지급을, 달성하지 못하면 후원금을 환불하는 행위이다.

## Code 구현

1. .sol 파일 구조 및 컨트랙트 작성

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Fundraising {
  // 채워나갈곳
}
```

2. value 선언 (uint = uint256 / 8,16같이 숫자를 적어두지 않으면 256으로 default 갖는다.)

```solidity
address public owner;
// 소유주 (해당 contract)
uint public targetAmount;
// 목표량
mapping(address => uint) public donations;
// {후원한계좌 : 후원한양}
uint raisedAmount =0;
// 모여있는 후원양
uint public finishTime = block.timestamp + 2 weeks;
// 기한
```

3. constructor 설정 (목표총량, owner)

```solidity
constructor(uint _targetAmount) {
  targetAmount = _targetAmount;
  owner = msg.sender;
}
```

4. 기능구현
   4-1. 후원받는 기능
   - fund에 돈을 송금하면 실행된다.
   - 특이사항
     - external : 해당 contract 외부에서만 접근 가능
     - payable : 송금기능이 있다.
     - require() : 안의 조건을 만족하면 넘어가고, 만족하지 못하면 끝낸다.
     - require(조건식, error) : 조건을 만족하지 못하면 error 문을 출력한다.

```solidity
receive() external payable {
  require(block.timestamp < finishTime, "This funding is over");
  donations[msg.sender] += msg.value;
  raisedAmount += msg.value;
}
```

4-2. 성공적으로 펀딩되었을 때의 기능 - funding의 기간이 만료되었을, 모인 후원금을 owner에게 전송해주는 역할을 한다.

    ```solidity
     function withdrawDonations() external payable {
    require(msg.sender == owner, "Funds will only be released to the owner");
    require(raisedAmount >= targetAmount, "The funding didn't reach the goal");
    require(block.timestamp > finishTime, "The funding is not over yet");

    payable(owner).transfer(raisedAmount);

}

```
- msg.sender == owner : 모인 후원금을 받으려는 요청을 보낸 계정이 owner의 계정과 맞는가?
- raisedAmount >= targetAmount : 모인 후원금이 목표 금액량 이상인가?
- block.timestamp > finishTime : funding 기간이 지났는가?
```

4-3. funding 실패 시(모인 금액이 목표치보다 적을 때) 후원자들에게 환불해주는 기능

```solidity
function refund() external payable {
  require(block.timestamp > finishTime, "The funding is not over yet");
  require(raisedAmount < targetAmount, "The funding didn't reach the goal");
  require(donations[msg.sender] > 0, "You didn't donate to this funding");

  uint toRefund = donations[msg.sender];
  donations[msg.sender] = 0;
  payable(msg.sender).transfer(toRefund);
}
```

- block.timestamp > finishTime : funding 기간이 지났는가?
- raisedAmount < targetAmount : 목표치를 달성하지 못했는가?
- donations[msg.sender] > 0 : request를 보낸 계정이 후원한 금액이 있는가?
- 후원한 금액이 있다면 임시변수 toRefund에 금액량을 담아놓고, 후원했다는 mapping type donations[msg.sender] 를 0으로 초기화해준뒤 환불을 진행한다.
  - mapping data를 0으로 초기화하지않으면 요청을 보낼때마다 그 금액만큼 환불을 계속 받을 수 있기 때문.

---

위 기능이 핵심 기능으로 추가 기능 추가는 자유이다.

## 추가기능

1. 후원을 취소하는 기능

```solidity
function cancelFund() external payable {
  require(block.timestamp < finishTime, "The funding is over ");
  require(donations[msg.sender] > 0, "You didn't donate to this funding");

  uint toRefund = donations[msg.sender];
  donations[msg.sender] = 0;
  raisedAmount -= toRefund;
  payable(msg.sender).transfer(toRefund);
}
```

- block.timestamp < finishTime : funding 마감기한이 지나지 않았는가?
  - 지났으면 성공이든, 실패든 핵심기능이 동작한다.
- donations[msg.sender] > 0 : request를 보낸 계정이 후원한 금액이 있는가?
- 나머지 logic은 환불 logic과 같은데 raisedAmount -= toRefund;
  - 총 추원금에서 환불한 후원금을 빼준다.

2. 자신의 후원금을 확인할 수 있는 기능

```solidity
function getDonation() external view returns (uint) {
  return donations[msg.sender];
}
```

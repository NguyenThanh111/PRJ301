package Models;

public class VLANDTO {
    private int vlanId;
    private String vlanName;
    private String subnet;
    private String purpose;
    private Integer roomId;

    public VLANDTO() {
    }

    public VLANDTO(int vlanId, String vlanName, String subnet, String purpose, Integer roomId) {
        this.vlanId = vlanId;
        this.vlanName = vlanName;
        this.subnet = subnet;
        this.purpose = purpose;
        this.roomId = roomId;
    }

    public int getVlanId() {
        return vlanId;
    }

    public void setVlanId(int vlanId) {
        this.vlanId = vlanId;
    }

    public String getVlanName() {
        return vlanName;
    }

    public void setVlanName(String vlanName) {
        this.vlanName = vlanName;
    }

    public String getSubnet() {
        return subnet;
    }

    public void setSubnet(String subnet) {
        this.subnet = subnet;
    }

    public String getPurpose() {
        return purpose;
    }

    public void setPurpose(String purpose) {
        this.purpose = purpose;
    }

    public Integer getRoomId() {
        return roomId;
    }

    public void setRoomId(Integer roomId) {
        this.roomId = roomId;
    }

    @Override
    public String toString() {
        return "VLANDTO{" +
                "vlanId=" + vlanId +
                ", vlanName='" + vlanName + '\'' +
                ", subnet='" + subnet + '\'' +
                ", purpose='" + purpose + '\'' +
                ", roomId=" + roomId +
                '}';
    }
}
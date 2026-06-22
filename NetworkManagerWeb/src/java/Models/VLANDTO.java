
package Models;

import java.io.Serializable;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity(name = "VLAN")
@Table(name = "VLAN")
public class VLANDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "vlan_id")
    private int vlanId;

    @Column(name = "vlan_name", nullable = false, length = 100)
    private String vlanName;

    @Column(name = "subnet", length = 50)
    private String subnet;

    @Column(name = "purpose", length = 255)
    private String purpose;

    @Column(name = "room_id")
    private Integer roomId;
    
    public VLANDTO() {
    }

    public VLANDTO(int vlanId,
            String vlanName,
            String subnet,
            String purpose,
            Integer roomId) {

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
        return "VLANDTO{"
                + "vlanId=" + vlanId
                + ", vlanName='" + vlanName + '\''
                + ", subnet='" + subnet + '\''
                + ", purpose='" + purpose + '\''
                + ", roomId=" + roomId
                + '}';
    }
}

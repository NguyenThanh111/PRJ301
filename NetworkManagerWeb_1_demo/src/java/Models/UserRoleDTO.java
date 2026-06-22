package Models;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.Objects;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.Table;

@Entity
@Table(name = "UserRole")
@IdClass(UserRoleDTO.UserRoleId.class)
public class UserRoleDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "user_id")
    private int userId;

    @Id
    @Column(name = "role_id")
    private int roleId;

    @Column(name = "assigned_at")
    private Timestamp assignedAt;

    public UserRoleDTO() {
    }

    public UserRoleDTO(int userId, int roleId) {
        this.userId = userId;
        this.roleId = roleId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public Timestamp getAssignedAt() {
        return assignedAt;
    }

    public void setAssignedAt(Timestamp assignedAt) {
        this.assignedAt = assignedAt;
    }

    public static class UserRoleId implements Serializable {

        private static final long serialVersionUID = 1L;

        private int userId;
        private int roleId;

        public UserRoleId() {
        }

        public UserRoleId(int userId, int roleId) {
            this.userId = userId;
            this.roleId = roleId;
        }

        public int getUserId() {
            return userId;
        }

        public void setUserId(int userId) {
            this.userId = userId;
        }

        public int getRoleId() {
            return roleId;
        }

        public void setRoleId(int roleId) {
            this.roleId = roleId;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (!(o instanceof UserRoleId)) return false;
            UserRoleId that = (UserRoleId) o;
            return userId == that.userId && roleId == that.roleId;
        }

        @Override
        public int hashCode() {
            return Objects.hash(userId, roleId);
        }
    }
}
